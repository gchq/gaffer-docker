import json
import os
import sys
from kubespawner.spawner import KubeSpawner
from tornado import gen
from tornado.ioloop import IOLoop
from tornado.httpclient import AsyncHTTPClient, HTTPError as ClientHTTPError
from tornado.web import HTTPError as WebHTTPError
from traitlets import default
from z2jh import get_config
from kubespawner.reflector import ResourceReflector

AsyncHTTPClient.configure('tornado.curl_httpclient.CurlAsyncHTTPClient')

class KubeSpawnerWithNamespacedReflectors(KubeSpawner):
	reflectors = {
		"pods": {},
		"events": {},
	}

	@property
	def pod_reflector(self):
		if self.namespace not in self.__class__.reflectors['pods']:
			self._start_watching_pods()
		return self.__class__.reflectors['pods'][self.namespace]

	@property
	def event_reflector(self):
		if self.events_enabled:
			if self.namespace not in self.__class__.reflectors['events']:
				self._start_watching_events()
			return self.__class__.reflectors['events'][self.namespace]

	def _start_reflector(
		self,
		kind=None,
		reflector_class=ResourceReflector,
		replace=False,
		**kwargs,
	):
		main_loop = IOLoop.current()
		key = kind
		ReflectorClass = reflector_class

		def on_reflector_failure():
			self.log.critical("%s reflector failed, halting Hub.", key.title())
			sys.exit(1)

		previous_reflector = self.__class__.reflectors.get(key).get(self.namespace)
		if replace or not previous_reflector:
			self.__class__.reflectors[key][self.namespace] = ReflectorClass(
				parent=self,
				namespace=self.namespace,
				on_failure=on_reflector_failure,
				**kwargs,
			)

		if replace and previous_reflector:
			# we replaced the reflector, stop the old one
			previous_reflector.stop()

		# return the current reflector
		return self.__class__.reflectors[key][self.namespace]

class KubeSpawnerWithForwardOptionsServer(KubeSpawnerWithNamespacedReflectors):

	@default('options_form')
	def get_custom_options_form(self):
		return self.get_options_from_forward_server

	async def get_options_from_forward_server(self, current_spawner):
		self.log.info('options_form = {} {}'.format(self.user, self.profile_list))
		options_server_service_name = get_config('custom.optionsServerServiceName')
		url = 'http://{}/options'.format(options_server_service_name)
		http_client = AsyncHTTPClient()

		try:
			response = await http_client.fetch(url, method='POST', headers={'Content-Type': 'application/json'}, body=json.dumps({
				'username': self.user.name,
				'server_name': self._expand_user_properties('{servername}'),
				'pod_name': self.pod_name,
				'default_namespace': self.namespace
			}))
		except ClientHTTPError as e:
			self.log.info('http_request failed {} {}'.format(url, e))
			raise WebHTTPError(500, 'Error querying {} : {}'.format(url, e))

		data = json.loads(response.body)
		self.log.info('url response = {}'.format(data))
		return data['html']

	def options_from_form(self, formdata):
		self.log.info('User supplied options: {}'.format(formdata))
		return formdata

	async def run_prespawn_on_forward_server(self, profile, user_options):
		self.log.info('profile = {}'.format(profile))
		self.log.info('user_options = {}'.format(user_options))

		options_server_service_name = get_config('custom.optionsServerServiceName')
		url = 'http://{}/prespawn'.format(options_server_service_name)

		http_client = AsyncHTTPClient()

		try:
			response = await http_client.fetch(url, method='POST', headers={'Content-Type': 'application/json'}, body=json.dumps({
				'username': self.user.name,
				'server_name': self._expand_user_properties('{servername}'),
				'pod_name': self.pod_name,
				'default_namespace': self.namespace,
				'user_options': user_options,
				'profile': profile
			}))
		except ClientHTTPError as e:
			self.log.info('http_request failed {} {}'.format(url, e))
			raise WebHTTPError(500, 'Error querying {} : {}'.format(url, e))

		data = json.loads(response.body)
		self.log.info('url response = {}'.format(data))
		return data

	async def _load_profile(self, slug):
		slug = slug[0]

		self.log.info('_load_profile user_options = {}'.format(self.user_options))
		self.log.info('_load_profile slug = {}'.format(slug))

		selected_profile = None
		for profile in self._profile_list:
			if profile.get('slug', '') == slug:
				selected_profile = profile
				break
		if not selected_profile:
			raise ValueError('Profile not found: {}, available profiles: {}'.format(slug, ' '.join(p['slug'] for p in self._profile_list)))

		self.log.debug("Applying KubeSpawner override for profile %s", selected_profile['slug'])
		kubespawner_override = selected_profile.get('kubespawner_override', {})
		for k, v in kubespawner_override.items():
			if callable(v):
				v = v(self)
				self.log.debug("... overriding KubeSpawner value %s=%s (callable result)", k, v)
			else:
				self.log.debug("... overriding KubeSpawner value %s=%s", k, v)
			setattr(self, k, v)

		self.log.info('profile = {}'.format(slug))
		response = await self.run_prespawn_on_forward_server(slug, self.user_options)
		self.log.info('await response = {}'.format(response))

		self.log.debug('Applying overrides for profile %s from forward options server...', slug)

		if 'namespace' in response:
			self.log.debug('Setting namespace = %s', response['namespace'])
			self.namespace = response['namespace']

		if 'labels' in response:
			for key, value in response['labels'].items():
				self.log.debug('Adding label: %s = %s', key, value)
				self.extra_labels[key] = value

		if 'env' in response:
			for key, value in response['env'].items():
				self.log.debug('Setting env var: %s = %s', key, value)
				self.environment[key] = value

		if 'serviceAccount' in response:
			self.service_account = response['serviceAccount']

		if 'resources' in response:
			for key in [key for key in response['resources'].keys() if key in [
				'cpu_guarantee',
				'cpu_limit',
				'mem_guarantee',
				'mem_limit',
				'storage_capacity'
			]]:
				self.log.debug('Setting resource: %s = %s', key, response['resources'][key])
				setattr(self, key, response['resources'][key])

		if 'pvc_name' in response:
			self.log.debug('Setting pvc_name to: %s', response['pvc_name'])
			self.pvc_name = response['pvc_name']

		if 'storage_extra_labels' in response:
			for key, value in response['storage_extra_labels'].items():
				self.log.debug('Adding storage label: %s = %s', key, value)
				self.storage_extra_labels[key] = value

		if 'volumes' in response:
			for volume in response['volumes']:
				self.log.debug('Adding volume: %s', volume)
				self.volumes.append(volume)

		if 'volumeMounts' in response:
			for volumeMount in response['volumeMounts']:
				self.log.debug('Adding volumeMount: %s', volumeMount)
				self.volume_mounts.append(volumeMount)

c.JupyterHub.spawner_class = KubeSpawnerWithForwardOptionsServer

# Ensure notebooks connect to the hub using the full service DNS name so that they can be deployed in different namespaces
c.JupyterHub.hub_connect_url = 'http://hub.{}.svc:{}'.format(
	os.environ['POD_NAMESPACE'],
	os.environ['HUB_SERVICE_PORT']
)
