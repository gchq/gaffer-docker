
const fs = require('fs')
const yaml = require('js-yaml')
const K8sWatcher = require('./k8s-watcher')
const K8sUtils = require('./k8s-utils.js')

const DEFAULT_STATIC_CONFIG_FILE_PATH = __dirname + '/../conf/hdfs.yaml'
const DEFAULT_HADOOP_CONF_MOUNT_PATH = '/etc/hadoop/conf'
const DEFAULT_HADOOP_CONF_TEMPLATES_DIR = __dirname + '/../templates/hadoop/'

class HdfsInstanceDirectory {

	constructor(kubeConfig, staticConfigFilePath, hadoopConfigMountPath, hadoopConfigTemplatesDirectory) {
		this.staticConfigFilePath = staticConfigFilePath || DEFAULT_STATIC_CONFIG_FILE_PATH
		this.hadoopConfigMountPath = hadoopConfigMountPath || DEFAULT_HADOOP_CONF_MOUNT_PATH
		this.hadoopConfigTemplatesDirectory = hadoopConfigTemplatesDirectory || DEFAULT_HADOOP_CONF_TEMPLATES_DIR

		this.static = new Map()
		this.dynamic = new Map()

		this.loadConfigFile(this.staticConfigFilePath)

		this.utils = new K8sUtils(kubeConfig)

		this.watcher = new K8sWatcher(kubeConfig, '/api/v1/services', {
			labelSelector: 'app.kubernetes.io/name=hdfs,app.kubernetes.io/component=namenode'
		})
		this.watcher.on('RESET', () => this.dynamic = new Map())
		this.watcher.on('ADDED', (instance) => this.addDynamicInstance(instance))
		this.watcher.on('MODIFIED', (instance) => this.addDynamicInstance(instance))
		this.watcher.on('DELETED', (instance) => this.removeDynamicInstance(instance))
	}

	loadConfigFile(configFile) {
		if (fs.existsSync(configFile)) {
			const config = yaml.safeLoad(fs.readFileSync(configFile, 'utf8'))
			config.forEach(instance => {
				console.log('Loaded static HDFS instance config from', configFile, ':', JSON.stringify(instance))
				this.static.set(instance.id, instance)
			})
		}
	}

	addDynamicInstance(instance) {
		const instanceName = instance.metadata.labels['app.kubernetes.io/instance']
		const id = instance.metadata.namespace + ':' + instanceName

		let clientRpcPort = instance.spec.ports.filter(port => port.name == 'client-rpc').map(port => ':' + port.port).pop()
		const namenodeClientRpcUrl = 'hdfs://' + instance.metadata.name + '.' + instance.metadata.namespace + '.svc' + (clientRpcPort ? clientRpcPort : '')

		const info = {
			id: id,
			name: instanceName,
			namespace: instance.metadata.namespace,
			namenodeClientRpcUrl: namenodeClientRpcUrl
		}
		console.log('Added dynamic HDFS instance config from K8s:', JSON.stringify(info))
		this.dynamic.set(id, info)
	}

	removeDynamicInstance(instance) {
		const instanceName = instance.metadata.labels['app.kubernetes.io/instance']
		const id = instance.metadata.namespace + ':' + instanceName

		console.log('Removed dynamic HDFS instance config from K8s:', id)
		this.dynamic.delete(id)
	}

	getForUser(username) {
		const dynamicInstancesForUser = Array.from(this.dynamic.entries())
			.filter(([id, instance]) => !this.static.has(id) || ! ('users' in this.static.get(id)) || this.static.get(id).users.length == 0 || this.static.get(id).users.includes(username))

		const staticInstancesForUser = Array.from(this.static.entries())
			.filter(([id, instance]) => !this.dynamic.has(id) && 'namenodeClientRpcUrl' in instance && (! ('users' in instance) || instance.users.length == 0 || instance.users.includes(username)))

		const allInstancesForUser = new Map(dynamicInstancesForUser.concat(staticInstancesForUser))
		return allInstancesForUser
	}

	async provisionHadoopConfigMap(name, namespace, instance, username, servername) {
		const configMap = await this.utils.generateConfigMapSpecForDirectoryOfTemplates(name, namespace, this.hadoopConfigTemplatesDirectory, {
			'NAMENODE_CLIENT_RPC_URL': instance.namenodeClientRpcUrl
		})

		if (! ('labels' in configMap.metadata))
			configMap.metadata['labels'] = {}

		configMap.metadata.labels['app.kubernetes.io/name'] = 'jhub-notebook-config'
		configMap.metadata.labels['app.kubernetes.io/component'] = 'hadoop-config'
		configMap.metadata.labels['app.kubernetes.io/instance'] = instance.name

		const appInfo = require('../package.json')
		configMap.metadata.labels['app.kubernetes.io/managed-by'] = appInfo.name
		configMap.metadata.labels['app.kubernetes.io/version'] = appInfo.version

		configMap.metadata.labels['hub.jupyter.org/username'] = username
		configMap.metadata.labels['hub.jupyter.org/servername'] = servername

		const response = await this.utils.applySpec(configMap)
		return response
	}

	async getPodSpecConfigForHdfsInstance(id, username, servername, namespace) {
		const instance = this.dynamic.get(id) || this.static.get(id)
		if (!instance) throw 'HDFS instance not found: ' + id

		const configMap = await this.provisionHadoopConfigMap('jhub-hadoop-config-' + username + (servername ? '-' + servername : ''), namespace, instance, username, servername)

		const config = {
			'env': {
				'HADOOP_CONF_DIR': this.hadoopConfigMountPath,
				'HADOOP_USER_NAME': username
			},
			'volumes': [
				{
					'name': 'hadoop-config',
					'configMap': {
						'name': configMap.metadata.name,
						'optional': false
					}
				}
			],
			'volumeMounts': [
				{
					'name': 'hadoop-config',
					'mountPath': this.hadoopConfigMountPath,
					'readOnly': true
				}
			]
		}
		return config
	}

}

module.exports = HdfsInstanceDirectory
