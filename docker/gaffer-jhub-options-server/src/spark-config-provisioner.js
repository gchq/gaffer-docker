
const appInfo = require('../package.json')
const fs = require('fs')
const yaml = require('js-yaml')
const K8sUtils = require('./k8s-utils.js')

const DEFAULT_STATIC_SPARK_PROPERTIES_FILE_PATH = __dirname + '/../conf/spark-defaults.yaml'
const DEFAULT_NOTEBOOK_CONFIG_TEMPLATES_DIRECTORY = __dirname + '/../templates/spark/notebook/'
const DEFAULT_NOTEBOOK_CONFIG_MOUNT_PATH = '/opt/spark/conf'
const DEFAULT_UI_PORT = 4040

class SparkConfigProvisioner {

	constructor(kubeConfig, staticSparkPropertiesFilePath, notebookConfigTemplatesDirectory, notebookConfigMountPath) {
		this.utils = new K8sUtils(kubeConfig)
		this.staticSparkPropertiesFilePath = staticSparkPropertiesFilePath || DEFAULT_STATIC_SPARK_PROPERTIES_FILE_PATH
		this.notebookConfigTemplatesDirectory = notebookConfigTemplatesDirectory || DEFAULT_NOTEBOOK_CONFIG_TEMPLATES_DIRECTORY
		this.notebookConfigMountPath = notebookConfigMountPath || DEFAULT_NOTEBOOK_CONFIG_MOUNT_PATH

		this.staticProperties = {}
		this.loadSparkPropertiesFromFile(this.staticSparkPropertiesFilePath)
	}

	loadSparkPropertiesFromFile(configFilePath) {
		if (fs.existsSync(configFilePath)) {
			const config = yaml.safeLoad(fs.readFileSync(configFilePath, 'utf8'))
			// console.log(JSON.stringify(config, null, 2))

			Object.keys(config).forEach(propertyName => {
				const propertyValue = config[propertyName]
				console.log('Loaded static Spark Property: ' + propertyName + ' = ' + propertyValue)
				this.staticProperties[propertyName] = propertyValue
			})
		}
	}

	getSparkDefaultProperties(containerImage, namespace, username, servername, serviceAccountName, executorCores, executorMemory, hdfsEnabled) {
		const props = Object.assign({
			'spark.ui.port': DEFAULT_UI_PORT
		}, this.staticProperties)

		props['spark.kubernetes.container.image'] = containerImage
		props['spark.kubernetes.namespace'] = namespace
		props['spark.kubernetes.executor.podTemplateFile'] = this.notebookConfigMountPath + '/executor-pod.yaml'
		if (serviceAccountName) {
			props['spark.kubernetes.authenticate.driver.serviceAccountName'] = serviceAccountName
		}

		props['spark.kubernetes.driver.label.app.kubernetes.io/managed-by'] = appInfo.name
		props['spark.kubernetes.driver.label.app.kubernetes.io/version'] = appInfo.version
		props['spark.kubernetes.driver.label.hub.jupyter.org/username'] = username
		props['spark.kubernetes.driver.label.hub.jupyter.org/servername'] = servername

		props['spark.kubernetes.executor.label.app.kubernetes.io/managed-by'] = appInfo.name
		props['spark.kubernetes.executor.label.app.kubernetes.io/version'] = appInfo.version
		props['spark.kubernetes.executor.label.hub.jupyter.org/username'] = username
		props['spark.kubernetes.executor.label.hub.jupyter.org/servername'] = servername

		props['spark.kubernetes.executor.request.cores'] = executorCores || '250m'
		props['spark.kubernetes.executor.limit.cores'] = executorCores || '250m'

		props['spark.executor.memory'] = executorMemory ? executorMemory + 'm' : '1g'

		if (hdfsEnabled) {
			props['spark.eventLog.enabled'] = 'true'
			props['spark.eventLog.dir'] = 'hdfs:///user/' + username + '/spark-logs/'
		}

		return props
	}

	async provisionNotebookConfig(name, namespace, username, servername, sparkProperties) {
		const configMap = await this.utils.generateConfigMapSpecForDirectoryOfTemplates(name, namespace, this.notebookConfigTemplatesDirectory, {})
		configMap.data['spark-defaults.conf'] = Object.entries(sparkProperties).map(([key, value]) => key + ' ' + value).join("\n")

		if (! ('labels' in configMap.metadata))
			configMap.metadata['labels'] = {}

		configMap.metadata.labels['app.kubernetes.io/name'] = 'jhub-notebook-config'
		configMap.metadata.labels['app.kubernetes.io/component'] = 'notebook-spark-config'
		configMap.metadata.labels['app.kubernetes.io/managed-by'] = appInfo.name
		configMap.metadata.labels['app.kubernetes.io/version'] = appInfo.version
		configMap.metadata.labels['hub.jupyter.org/username'] = username
		configMap.metadata.labels['hub.jupyter.org/servername'] = servername

		const response = await this.utils.applySpec(configMap)
		return response
	}

	async provisionDriverService(name, namespace, username, servername, port) {
		const svc = {
			apiVersion: 'v1',
			kind: 'Service',
			metadata: {
				name: name,
				namespace: namespace,
				labels: {
					'app.kubernetes.io/name': 'jhub-notebook-config',
					'app.kubernetes.io/component': 'spark-driver-service',
					'app.kubernetes.io/managed-by': appInfo.name,
					'app.kubernetes.io/version': appInfo.version,
					'hub.jupyter.org/username': username,
					'hub.jupyter.org/servername': servername,
					'hub.jupyter.org/servicename': name
				}
			},
			spec: {
				type: 'ClusterIP',
				clusterIP: 'None',
				selector: {
					'app.kubernetes.io/component': 'jhub-notebook',
					'hub.jupyter.org/username': username,
					'hub.jupyter.org/servername': servername,
					'hub.jupyter.org/servicename': name
				},
				ports: [{
					name: 'http',
					port: port,
					targetPort: port
				}]
			}
		}

		const response = await this.utils.applySpec(svc)
		return response
	}

	async provisionDriverIngress(name, namespace, host, path, serviceName, servicePort, username, servername) {
		if (!host && !path) return null

		const ingressPath = {
			backend: {
				serviceName: serviceName,
				servicePort: servicePort
			}
		}
		if (path) ingressPath.path = path

		const rule = {
			http: {
				paths: [ingressPath]
			}
		}
		if (host) rule.host = host

		const ingress = {
			apiVersion: 'extensions/v1beta1',
			kind: 'Ingress',
			metadata: {
				name: name,
				namespace: namespace,
				labels: {
					'app.kubernetes.io/name': 'jhub-notebook-config',
					'app.kubernetes.io/component': 'spark-ui-ingress',
					'app.kubernetes.io/managed-by': appInfo.name,
					'app.kubernetes.io/version': appInfo.version,
					'hub.jupyter.org/username': username,
					'hub.jupyter.org/servername': servername
				}
			},
			spec: {
				rules: [rule]
			}
		}

		const response = await this.utils.applySpec(ingress)
		return response
	}

	async getPodSpecConfig(username, servername, driverServiceName, namespace, sparkContainerImage, serviceAccountName, executorCores, executorMemory, hdfsEnabled, ingressHost, ingressPath) {
		const sparkProperties = this.getSparkDefaultProperties(sparkContainerImage, namespace, username, servername, serviceAccountName, executorCores, executorMemory, hdfsEnabled)
		const uiPort = sparkProperties['spark.ui.port']

		const [configMap, service, ingress] = await Promise.all([
			this.provisionNotebookConfig('jhub-spark-config-' + username + (servername ? '-' + servername : ''), namespace, username, servername, sparkProperties),
			this.provisionDriverService(driverServiceName, namespace, username, servername, uiPort),
			this.provisionDriverIngress(driverServiceName + '-spark-ui', namespace, ingressHost, ingressPath, driverServiceName, uiPort, username, servername)
		])

		const config = {
			'labels': service.spec.selector,
			'env': {
				'SPARK_UI_URL': 'https://' + ingressHost + (ingressPath ? ingressPath : '')
			},
			'volumes': [
				{
					'name': 'spark-config',
					'configMap': {
						'name': configMap.metadata.name,
						'optional': false
					}
				}
			],
			'volumeMounts': [
				{
					'name': 'spark-config',
					'mountPath': this.notebookConfigMountPath,
					'readOnly': true
				}
			]
		}
		return config
	}

}

module.exports = SparkConfigProvisioner
