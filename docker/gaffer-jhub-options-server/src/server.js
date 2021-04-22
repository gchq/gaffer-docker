
const PORT = process.argv.length >= 3 ? process.argv[2] : 8080

const fs = require('fs')
const k8s = require('@kubernetes/client-node')
const pug = require('pug')
const express = require('express')
const body_parser = require('body-parser')

const VolumeLookup = require('./volumes.js')
const NamespaceLookup = require('./namespaces.js')
const HdfsInstanceDirectory = require('./hdfs.js')
const K8sServiceAccountDirectory = require('./service-accounts.js')
const GafferGraphDirectory = require('./gaffer-graphs.js')
const SparkConfigProvisioner = require('./spark-config-provisioner.js')
const ProfileDirectory = require('./profiles.js')
const { renderTemplate } = require('./templating.js')

const kubeConfig = new k8s.KubeConfig()
kubeConfig.loadFromDefault()

const volumeLookup = new VolumeLookup(kubeConfig)
const namespaceLookup = new NamespaceLookup(null, kubeConfig)
const hdfsInstances = new HdfsInstanceDirectory(kubeConfig)
const serviceAccounts = new K8sServiceAccountDirectory(kubeConfig)
const gafferGraphs = new GafferGraphDirectory(kubeConfig)
const sparkConfigProvisioner = new SparkConfigProvisioner(kubeConfig)
const profiles = new ProfileDirectory()

const profileListTemplate = pug.compileFile(__dirname + '/../templates/profile_list.pug')
const profileFormScript = fs.readFileSync(__dirname + '/../templates/profile_form.js', 'utf8')

function logRequest (req) {
	console.log(JSON.stringify({
		method: req.method,
		url: req.url,
		headers: req.headers,
		body: req.body
	}))
}

function mergeObjects (target, source) {
	return Object.entries(source)
		.reduce((target, [k, v]) => {
			if (Array.isArray(v)) {
				if (! (k in target)) target[k] = []
				target[k] = target[k].concat(v)
			} else if (typeof v == 'object') {
				if (! (k in target)) target[k] = {}
				target[k] = mergeObjects(target[k], v)
			} else if (typeof v == 'string' || typeof v == 'number') {
				if (k in target) console.error('Warning: Overriding key "' + k + '" with value "' + v + '", previous value was "' + target[k] + '"')
				target[k] = v
			} else {
				throw 'Unable to merge "' + k + '" key with value of type: ' + typeof v
			}

			return target
		}, target)
}

const app = express()
app.use(body_parser.json())

app.get('/', (req, res) => {
	return res.status(200).send()
})

app.post('/options', (req, res) => {
	logRequest(req)

	if (!req.body.username)
		return res.status(400).send('Missing username parameter')
	if (! ('server_name' in req.body))
		return res.status(400).send('Missing server_name parameter')

	return Promise.all([
		namespaceLookup.getForUser(req.body.username),
		hdfsInstances.getForUser(req.body.username),
		gafferGraphs.getForUser(req.body.username)
	]).then(([namespaces, hdfsInstances, graphs]) => [
		namespaces,
		hdfsInstances,
		graphs,
		serviceAccounts.getForUser(req.body.username, namespaces),
		volumeLookup.getForUser(req.body.username, namespaces)
	]).then(([namespaces, hdfsInstances, graphs, serviceAccounts, volumes]) => {

		const data = {
			username: req.body.username,
			servername: req.body.server_name,
			profiles: profiles.getLookup(),
			default_namespace: 'default_namespace' in req.body ? req.body.default_namespace : null,
			namespaces: namespaces.reduce((acc, namespace) => {
				acc[namespace] = {
					name: namespace,
					volumes: [],
					serviceAccounts: []
				}
				return acc
			}, {}),
			hdfs: Array.from(hdfsInstances.values()),
			graphs: Array.from(graphs.values()).map(graph => {
				return {
					id: graph.id,
					name: graph.name,
					description: graph.graphConfig.description
				}
			})
		}

		Array.from(serviceAccounts.values()).forEach(serviceAccount => {
			data.namespaces[serviceAccount.namespace].serviceAccounts.push(serviceAccount)
		})
		Array.from(volumes.values()).forEach(volume => {
			data.namespaces[volume.namespace].volumes.push(volume)
		})

		const js = '<script type="text/javascript">const PROFILE_FORM_DATA=JSON.parse(\'' + JSON.stringify(data) + '\');' + profileFormScript + '</script>'
		const tpl = profileListTemplate(data)
		data.html = js + tpl

		return data
	}).then(data => {
		return res.status(200).json(data)
	}).catch(err => {
		console.error(err)
		return res.status(500).send()
	})
})

app.post('/prespawn', (req, res) => {
	logRequest(req)

	if (!req.body.username)
		return res.status(400).send('Missing username parameter')
	if (! ('server_name' in req.body))
		return res.status(400).send('Missing server_name parameter')
	if (!req.body.pod_name)
		return res.status(400).send('Missing pod_name parameter')
	if (!req.body.default_namespace)
		return res.status(400).send('Missing default_namespace parameter')
	if (!req.body.user_options)
		return res.status(400).send('Missing user_options parameter')
	if (!req.body.profile)
		return res.status(400).send('Missing profile parameter')

	const profile = profiles.getForSlug(req.body.profile)
	if (!profile)
		return res.status(400).send('Unable to find profile:' + req.body.profile)

	const user_options = {}
	for (const key in req.body.user_options) {
		const values = req.body.user_options[key]
		if (Array.isArray(values) && values.length == 1) {
			user_options[key] = values[0]
		} else {
			user_options[key] = values
		}
	}

	prespawn(req.body.username, req.body.server_name, req.body.pod_name, req.body.default_namespace, user_options, profile)
		.then(config => {
			return res.status(200).json(config)
		})
		.catch(err => {
			console.error(err)
			return res.status(500).send(err)
		})
})

const prespawn = async (username, server_name, pod_name, default_namespace, user_options, profile) => {
	const config = {
		namespace: default_namespace,
		env: {},
		resources: {},
		volumes: [],
		volumeMounts: []
	}

	return await Promise.all([
		namespaceLookup.getForUser(username),
		profile.enable_hdfs ? hdfsInstances.getForUser(username) : new Map(),
		profile.enable_gaffer ? gafferGraphs.getForUser(username) : new Map()
	]).then(([allowedNamespaces, allowedHdfsInstances, allowedGraphs]) => [
		allowedNamespaces,
		allowedHdfsInstances,
		allowedGraphs,
		serviceAccounts.getForUser(username, allowedNamespaces)
	]).then(async ([
		allowedNamespaces,
		allowedHdfsInstances,
		allowedGraphs,
		allowedServiceAccounts
	]) => {

		if ('volume' in user_options && user_options.volume) {
			const podSpec = volumeLookup.getPodSpecForExistingVolume(user_options.volume, username, server_name)
			mergeObjects(config, podSpec)
		} else if ('volume_name' in user_options && user_options.volume_name) {
			const podSpec = volumeLookup.getPodSpecConfigForNewVolume(user_options.volume_name, username, server_name)
			mergeObjects(config, podSpec)
		} else {
			const podSpec = volumeLookup.getPodSpecConfigForNewVolume(server_name || 'default', username, server_name)
			mergeObjects(config, podSpec)
		}

		if ('resources_cpu' in user_options) {
			config['resources']['cpu_guarantee'] = parseFloat(user_options['resources_cpu'])
			config['resources']['cpu_limit'] = config['resources']['cpu_guarantee']
		}

		if ('resources_mem' in user_options) {
			config['resources']['mem_guarantee'] = user_options['resources_mem'] + 'M'
			config['resources']['mem_limit'] = config['resources']['mem_guarantee']
		}

		if ('resources_hdd' in user_options) {
			config['resources']['storage_capacity'] = user_options['resources_hdd'] + 'G'
		}

		if ('k8s_namespace' in user_options && user_options.k8s_namespace.length > 0) {
			if (allowedNamespaces.indexOf(user_options.k8s_namespace) > -1) {
				config['namespace'] = user_options.k8s_namespace
			} else {
				throw `Invalid namespace requested: ${user_options.k8s_namespace}. Allowed namespaces: ${allowedNamespaces}`
			}
		}

		let hdfsEnabled = false
		if (profile.enable_hdfs && 'hdfs' in user_options && user_options.hdfs.length > 0) {
			const hdfsInstance = allowedHdfsInstances.get(user_options.hdfs)
			if (hdfsInstance) {
				hdfsEnabled = true
				const podSpec = await hdfsInstances.getPodSpecConfigForHdfsInstance(hdfsInstance.id, username, server_name, config.namespace)
				mergeObjects(config, podSpec)
			} else {
				throw `Invalid HDFS instance requested: ${user_options.hdfs}. Available instances: ${Array.from(allowedHdfsInstances.keys())}`
			}
		}

		if ('k8s_service_account' in user_options && user_options.k8s_service_account.length > 0) {
			const serviceAccount = allowedServiceAccounts.get(user_options.k8s_service_account)
			if (serviceAccount) {
				const podSpec = serviceAccounts.getPodSpecConfig(serviceAccount.id)
				mergeObjects(config, podSpec)
			} else {
				throw `Invalid K8s Service Account requested: ${user_options.k8s_service_account}. Available service accounts: ${Array.from(allowedServiceAccounts.keys())}`
			}
		}

		if (profile.enable_gaffer && 'gaffer_graph' in user_options && user_options.gaffer_graph.length > 0) {
			const graph = allowedGraphs.get(user_options.gaffer_graph)
			if (graph) {
				const podSpec = await gafferGraphs.getPodSpecConfig(graph, username, server_name, config.namespace)
				mergeObjects(config, podSpec)
			} else {
				throw `Invalid Gaffer Graph requested: ${user_options.gaffer_graph}. Available graphs: ${Array.from(allowedGraphs.keys())}`
			}
		}

		if (profile.enable_spark) {
			if (!profile.spark_image) {
				throw `${profile.slug} profile does not specify which spark image to use!`
			}

			const podSpec = await sparkConfigProvisioner.getPodSpecConfig(
				username,
				server_name,
				pod_name,
				config.namespace,
				profile.spark_image,
				'serviceAccount' in config ? config.serviceAccount : null,
				user_options.spark_cpu,
				user_options.spark_mem,
				hdfsEnabled,
				renderTemplate(profile.spark_ingress_host, {
					USERNAME: username,
					SERVERNAME: server_name || 'default'
				}),
				profile.spark_ingress_path == null ? null : renderTemplate(profile.spark_ingress_path, {
					USERNAME: username,
					SERVERNAME: server_name || 'default'
				})
			)
			mergeObjects(config, podSpec)
		}

		return config
	})
}

app.listen(PORT, () => console.log(`Listening on port ${PORT}...`))
