
import requests
import time
import kubernetes
import os

HUB_API_URL = os.environ['HUB_API_URL']
OPTIONS_SERVER_URL = os.environ['OPTIONS_SERVER_URL']
API_TOKEN = os.environ['API_TOKEN']
USERNAME = 'hadoop'
SERVERNAME = 'testing'
NAMESPACE = os.environ['NAMESPACE']
SERVICE_ACCOUNT_NAME = os.environ['SERVICE_ACCOUNT_NAME']

kubernetes.config.load_incluster_config()

r = requests.Session()
r.headers.update({ 'Authorization': 'token {}'.format(API_TOKEN) })

def get_notebook_spawn_options(username, servername):
	url = '{}/options'.format(OPTIONS_SERVER_URL)
	response = r.post(url, json={
		'username': username,
		'server_name': servername
	})
	assert response.ok
	return response.json()

def get_jhub_info():
	url = '{}/info'.format(HUB_API_URL)
	response = r.get(url)
	assert response.ok
	return response.json()

def get_user_info(username):
	url = '{}/users/{}'.format(HUB_API_URL, username)
	response = r.get(url)
	assert response.ok
	return response.json()

def ensure_user_exists(username):
	url = '{}/users/{}'.format(HUB_API_URL, username)
	response = r.post(url)
	assert response.ok or response.status_code == 409

def spawn_user_notebook(username, servername, options = {}, timeout=60*5):
	delete_user_notebook(username, servername, timeout)

	print('Spawning notebook server: {}/{}'.format(username, servername))
	print('Notebook options: {}'.format(options))
	url = '{}/users/{}/servers/{}'.format(HUB_API_URL, username, servername)
	response = r.post(url, json=options)
	print(response.status_code, response.text)
	assert response.ok

	end_time = time.time() + timeout
	while time.time() < end_time:
		user = get_user_info(username)
		if servername not in user['servers']:
			raise Exception('Unable to retrieve information about notebook server: {}/{}'.format(username, servername))

		server_info = user['servers'][servername]
		if server_info['ready']:
			return server_info

		time.sleep(1)

	raise Exception('Timed out waiting for notebook server to be ready: {}/{}'.format(username, servername))

def delete_user_notebook(username, servername, timeout=60*5):
	user = get_user_info(username)
	if servername not in user['servers']:
		return True

	print('Deleting notebook server: {}/{}'.format(username, servername))
	url = '{}/users/{}/servers/{}'.format(HUB_API_URL, username, servername)
	response = r.delete(url)
	assert response.ok

	end_time = time.time() + timeout
	while time.time() < end_time:
		user = get_user_info(username)
		if servername not in user['servers']:
			return True
		time.sleep(1)

	raise Exception('Timed out waiting for notebook server to be deleted: {}/{}'.format(username, servername))

def exec_command_in_pod(pod_name, namespace, cmd):
	api = kubernetes.client.api.core_v1_api.CoreV1Api()

	exec_command = ['/bin/bash', '-c', cmd]
	response = kubernetes.stream.stream(
		api.connect_get_namespaced_pod_exec,
		pod_name,
		namespace,
		command=exec_command,
		stderr=True,
		stdin=False,
		stdout=True,
		tty=False,
		_preload_content=False
	)

	response.run_forever()
	return_code = response.returncode
	output = response.read_all()

	print(output)
	print('ReturnCode:', return_code)

	return return_code

def test_custom_kubespawner_is_being_used():
	info = get_jhub_info()
	assert info['spawner']['class'] == 'builtins.KubeSpawnerWithForwardOptionsServer'

def test_jhub_profiles(username, servername, namespace, service_account_name):
	ensure_user_exists(username)

	options = get_notebook_spawn_options(username, servername)
	for profile_slug in options['profiles']:
		profile = options['profiles'][profile_slug]
		print('')
		print('=== Testing profile {}: {}'.format(profile['slug'], profile['display_name']))
		print(profile)

		if namespace not in options['namespaces']:
			raise Exception('Unable to spawn any notebooks as user {} does not have permissions to the {} namespace!'.format(username, namespace))

		service_account_id = None
		for service_account in options['namespaces'][namespace]['serviceAccounts']:
			if service_account['name'] == service_account_name:
				service_account_id = service_account['id']
				break
		if not service_account_id:
			raise Exception('Unable to spawn any notebooks as the service account {} is not available to user {} in the {} namespace!'.format(service_account_name, username, namespace))

		server_options = {
			'profile': [profile['slug']],
			'k8s_namespace': [namespace],
			'k8s_service_account': [service_account_id]
		}
		if 'hdfs' in options and len(options['hdfs']) > 0:
			server_options['hdfs'] = [options['hdfs'][0]['id']]
		if 'graphs' in options and len(options['graphs']) > 0:
			server_options['gaffer_graph'] = [options['graphs'][0]['id']]

		try:
			server = spawn_user_notebook(username, servername, server_options)

			cmd = 'set -e; if [ -d /examples ]; then for file in /examples/*.ipynb; do echo Executing ${file}...; jupyter nbconvert ${file} --to python --stdout --execute --debug; done fi'
			rc = exec_command_in_pod(server['state']['pod_name'], namespace, cmd)
			assert rc == 0

		finally:
			delete_user_notebook(username, servername)

test_custom_kubespawner_is_being_used()

# E2E Test
# - Query options server and get a list of all available profiles and options
# - Spawn a Jupyter server for each profile
# - Check that all example notebooks run successfully
test_jhub_profiles(USERNAME, SERVERNAME, NAMESPACE, SERVICE_ACCOUNT_NAME)
