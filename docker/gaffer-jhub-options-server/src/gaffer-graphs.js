
const appInfo = require('../package.json')
const fs = require('fs')
const yaml = require('js-yaml')
const K8sWatcher = require('./k8s-watcher')
const K8sUtils = require('./k8s-utils.js')

const DEFAULT_STATIC_CONFIG_FILE_PATH = __dirname + '/../conf/graphs.yaml'
const DEFAULT_REST_API_URL_ENVIRONMENT_VARIABLE_NAME = 'GAFFER_REST_API_URL'
const DEFAULT_SCHEMA_MOUNT_PATH = '/etc/gaffer/schema/'
const DEFAULT_STORE_PROPERTIES_MOUNT_PATH = '/etc/gaffer/store/'
const DEFAULT_GRAPH_CONFIG_MOUNT_PATH = '/etc/gaffer/graph/'

class GafferGraphDirectory {

	constructor(kubeConfig, staticConfigFilePath, restApiUrlEnvironmentVariableName, schemaMountPath, storePropertiesMountPath, graphConfigMountPath) {
		this.staticConfigFilePath = staticConfigFilePath || DEFAULT_STATIC_CONFIG_FILE_PATH
		this.restApiUrlEnvironmentVariableName = restApiUrlEnvironmentVariableName || DEFAULT_REST_API_URL_ENVIRONMENT_VARIABLE_NAME
		this.schemaMountPath = schemaMountPath || DEFAULT_SCHEMA_MOUNT_PATH
		this.storePropertiesMountPath = storePropertiesMountPath || DEFAULT_STORE_PROPERTIES_MOUNT_PATH
		this.graphConfigMountPath = graphConfigMountPath || DEFAULT_GRAPH_CONFIG_MOUNT_PATH

		this.static = new Map()

		this.restApis = new Map()
		this.schemas = new Map()
		this.storeProperties = new Map()
		this.graphConfigs = new Map()

		this.loadConfigFile(this.staticConfigFilePath)

		this.utils = new K8sUtils(kubeConfig)

		this.svcWatcher = new K8sWatcher(kubeConfig, '/api/v1/services', {
			labelSelector: 'app.kubernetes.io/name=gaffer,app.kubernetes.io/component=api'
		})
		this.svcWatcher.on('RESET', () => this.restApis.clear())
		this.svcWatcher.on('ADDED', this.handleRestApiServiceAdded.bind(this))
		this.svcWatcher.on('MODIFIED', this.handleRestApiServiceAdded.bind(this))
		this.svcWatcher.on('DELETED', this.handleRestApiServiceRemoved.bind(this))

		this.cmWatcher = new K8sWatcher(kubeConfig, '/api/v1/configmaps', {
			labelSelector: 'app.kubernetes.io/name=gaffer'
		})
		this.cmWatcher.on('RESET', () => {
			this.schemas.clear()
			this.graphConfigs.clear()
		})
		this.cmWatcher.on('ADDED', this.handleConfigMapAdded.bind(this))
		this.cmWatcher.on('MODIFIED', this.handleConfigMapAdded.bind(this))
		this.cmWatcher.on('DELETED', this.handleConfigMapRemoved.bind(this))

		this.scrtWatcher = new K8sWatcher(kubeConfig, '/api/v1/secrets', {
			labelSelector: 'app.kubernetes.io/name=gaffer,app.kubernetes.io/component=store-properties'
		})
		this.scrtWatcher.on('RESET', () => this.storeProperties.clear())
		this.scrtWatcher.on('ADDED', this.handleStorePropertiesAdded.bind(this))
		this.scrtWatcher.on('MODIFIED', this.handleStorePropertiesAdded.bind(this))
		this.scrtWatcher.on('DELETED', this.handleStorePropertiesRemoved.bind(this))
	}

	loadConfigFile(configFile) {
		if (fs.existsSync(configFile)) {
			const config = yaml.safeLoad(fs.readFileSync(configFile, 'utf8'))
			config.forEach(graph => {
				console.log('Loaded static Gaffer Graph config from', configFile, ':', JSON.stringify(graph))
				this.static.set(graph.id, graph)
			})
		}
	}

	handleStorePropertiesAdded(secret) {
		const instanceName = secret.metadata.labels['app.kubernetes.io/instance']
		const id = secret.metadata.namespace + ':' + instanceName

		console.log('Discovered store properties for Gaffer Graph: ' + id + ' = ' + Object.keys(secret.data))
		this.storeProperties.set(id, {
			id: id,
			instance: instanceName,
			name: secret.metadata.name,
			namespace: secret.metadata.namespace,
			files: secret.data
		})
	}

	handleStorePropertiesRemoved(secret) {
		const instanceName = secret.metadata.labels['app.kubernetes.io/instance']
		const id = secret.metadata.namespace + ':' + instanceName
		console.log('Store properties for Gaffer Graph: ' + id + ' removed')
		this.storeProperties.delete(id)
	}

	handleConfigMapAdded(configmap) {
		const instanceName = configmap.metadata.labels['app.kubernetes.io/instance']
		const id = configmap.metadata.namespace + ':' + instanceName
		const component = configmap.metadata.labels['app.kubernetes.io/component']

		if (component == 'schema') {
			console.log('Discovered schema files for Gaffer Graph: ' + id + ' = ' + Object.keys(configmap.data))
			this.schemas.set(id, {
				id: id,
				instance: instanceName,
				name: configmap.metadata.name,
				namespace: configmap.metadata.namespace,
				files: configmap.data
			})

		} else if (component == 'graph-config') {
			const graphConfig = configmap.data
			console.log('Discovered graph config for Gaffer Graph: ' + id + ' = ' + Object.keys(graphConfig))
			this.graphConfigs.set(id, {
				id: id,
				instance: instanceName,
				name: configmap.metadata.name,
				namespace: configmap.metadata.namespace,
				files: graphConfig
			})

			if ('graphConfig.json' in graphConfig) {
				const parsedGraphConfig = JSON.parse(graphConfig['graphConfig.json'])
				if ('description' in parsedGraphConfig) {
					this.graphConfigs.get(id).description = parsedGraphConfig.description
				}
			}
		}
	}

	handleConfigMapRemoved(configmap) {
		const instanceName = configmap.metadata.labels['app.kubernetes.io/instance']
		const id = configmap.metadata.namespace + ':' + instanceName
		const component = configmap.metadata.labels['app.kubernetes.io/component']

		if (component == 'schema') {
			console.log('Schema for Gaffer Graph: ' + id + ' removed')
			this.schemas.delete(id)
		} else if (component == 'graph-config') {
			console.log('Graph config for Gaffer Graph: ' + id + ' removed')
			this.graphConfigs.delete(id)
		}
	}

	handleRestApiServiceAdded(service) {
		const instanceName = service.metadata.labels['app.kubernetes.io/instance']
		const id = service.metadata.namespace + ':' + instanceName

		const httpPort = service.spec.ports.filter(port => port.name == 'http').map(port => ':' + port.port).pop()
		const restApiUrl = 'http://' + service.metadata.name + '.' + service.metadata.namespace + '.svc' + (httpPort || '') + '/rest'

		console.log('Adding REST API URL for Gaffer Graph: ' + id + ' = ' + restApiUrl)
		this.restApis.set(id, {
			id: id,
			instance: instanceName,
			name: service.metadata.name,
			namespace: service.metadata.namespace,
			url: restApiUrl
		})
	}

	handleRestApiServiceRemoved(service) {
		const instanceName = service.metadata.labels['app.kubernetes.io/instance']
		const id = service.metadata.namespace + ':' + instanceName
		console.log('Removing REST API URL for Gaffer Graph: ' + instanceName)
		this.restApis.delete(id)
	}

	getForUser(username) {
		const dynamicGraphsForUser = Array.from(this.storeProperties.entries())
			.filter(([id, storeProperties]) =>
				!this.static.has(id) ||
				! ('users' in this.static.get(id)) ||
				this.static.get(id).users.length == 0 ||
				this.static.get(id).users.includes(username)
			).map(([id, storeProperties]) => {
				return [id, {
					id: id,
					name: storeProperties.instance,
					restApi: this.restApis.get(id),
					graphConfig: this.graphConfigs.get(id),
					schemas: this.schemas.get(id),
					storeProperties: storeProperties
				}]
			})

		const staticGraphsForUser = Array.from(this.static.entries())
			.filter(([id, graph]) =>
				!this.storeProperties.has(id) &&
				(
					! ('users' in graph) ||
					graph.users.length == 0 ||
					graph.users.includes(username)
				)
			)

		const allGraphsForUser = new Map(dynamicGraphsForUser.concat(staticGraphsForUser))
		return allGraphsForUser
	}

	async getPodSpecConfig(graph, username, servername, namespace) {
		const config = {
			'env': {},
			'volumes': [],
			'volumeMounts': []
		}

		if ('restApi' in graph && graph.restApi) {
			config.env.GAFFER_REST_API_URL = graph.restApi.url
		}

		const extraMounts = []

		if ('graphConfig' in graph && graph.graphConfig) {
			extraMounts.push(this.provisionConfigMap(
				graph.graphConfig,
				'jhub-gaffer-graph-config-' + username + (servername ? '-' + servername : ''),
				namespace,
				'graph-config',
				this.graphConfigMountPath,
				username,
				servername
			))
		}

		if ('schemas' in graph && graph.schemas) {
			extraMounts.push(this.provisionConfigMap(
				graph.schemas,
				'jhub-gaffer-schema-' + username + (servername ? '-' + servername : ''),
				namespace,
				'graph-schema',
				this.schemaMountPath,
				username,
				servername
			))
		}

		if ('storeProperties' in graph && graph.storeProperties) {
			extraMounts.push(this.provisionSecret(
				graph.storeProperties,
				'jhub-gaffer-store-' + username + (servername ? '-' + servername : ''),
				namespace,
				'graph-store-properties',
				this.storePropertiesMountPath,
				username,
				servername
			))
		}

		(await Promise.all(extraMounts)).forEach(mountConfig => {
			config.volumeMounts.push(mountConfig.mount)
			config.volumes.push(mountConfig.volume)
		})

		return config
	}

	async provisionConfigMap(configMapInfo, name, namespace, mountName, mountPath, username, servername) {
		if (configMapInfo.namespace == namespace) {
			// The source ConfigMap exists in the same namespace as the notebook, so we can just mount it
			return {
				mount: { name: mountName, mountPath: mountPath, readOnly: true },
				volume: { name: mountName, configMap: { name: configMapInfo.name, optional: false }}
			}
		}

		// Notebook is being deployed into a different namespace to the source ConfigMap so we need to deploy it
		const configMap = {
			'apiVersion': 'v1',
			'kind': 'ConfigMap',
			'metadata': {
				'name': name,
				'namespace': namespace,
				'labels': {
					'app.kubernetes.io/name': 'jhub-notebook-config',
					'app.kubernetes.io/component': mountName,
					'app.kubernetes.io/instance': configMapInfo.instance,
					'app.kubernetes.io/managed-by': appInfo.name,
					'app.kubernetes.io/version': appInfo.version,
					'hub.jupyter.org/username': username,
					'hub.jupyter.org/servername': servername
				}
			},
			'data': configMapInfo.files
		}
		await this.utils.applySpec(configMap)

		return {
			mount: { name: mountName, mountPath: mountPath, readOnly: true },
			volume: { name: mountName, configMap: { name: name, optional: false }}
		}
	}

	async provisionSecret(secretInfo, name, namespace, mountName, mountPath, username, servername) {
		if (secretInfo.namespace == namespace) {
			// The source Secret exists in the same namespace as the notebook, so we can just mount it
			return {
				mount: { name: mountName, mountPath: mountPath, readOnly: true },
				volume: { name: mountName, secret: { secretName: secretInfo.name, optional: false }}
			}
		}

		// Notebook is being deployed into a different namespace to the source Secret so we need to deploy it
		const secret = {
			'apiVersion': 'v1',
			'kind': 'Secret',
			'metadata': {
				'name': name,
				'namespace': namespace,
				'labels': {
					'app.kubernetes.io/name': 'jhub-notebook-config',
					'app.kubernetes.io/component': mountName,
					'app.kubernetes.io/instance': secretInfo.instance,
					'app.kubernetes.io/managed-by': appInfo.name,
					'app.kubernetes.io/version': appInfo.version,
					'hub.jupyter.org/username': username,
					'hub.jupyter.org/servername': servername
				}
			},
			'data': secretInfo.files
		}
		await this.utils.applySpec(secret)

		return {
			mount: { name: mountName, mountPath: mountPath, readOnly: true },
			volume: { name: mountName, secret: { secretName: name, optional: false }}
		}
	}

}

module.exports = GafferGraphDirectory
