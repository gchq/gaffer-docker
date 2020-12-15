
const fs = require('fs')
const yaml = require('js-yaml')
const pug = require('pug')
const k8s = require('@kubernetes/client-node')

const DEFAULT_CONFIG_FILE = 'conf/namespaces.yaml'

class NamespaceLookup {

	constructor(configFile, kubeConfig) {
		this.k8sClient = null
		this.templates = []
		this.static = new Map()

		if (kubeConfig) this.k8sClient = kubeConfig.makeApiClient(k8s.CoreV1Api)
		this.loadConfigFile(configFile || DEFAULT_CONFIG_FILE)
	}

	loadConfigFile(configFile) {
		if (fs.existsSync(configFile)) {
			const config = yaml.safeLoad(fs.readFileSync(configFile, 'utf8'))
			// console.log(JSON.stringify(config, null, 2))

			config.templated.forEach(templateString => {
				this.addNamespaceTemplate(templateString)
			})

			Object.entries(config.static).forEach(([name, users]) => this.addStaticNamespace(name, users))
		}
	}

	addStaticNamespace(name, users) {
		console.log('Adding static namespace: ' + name + ' for: ' + users)
		this.static.set(name, users)
	}

	addNamespaceTemplate(templateString) {
		console.log('Adding templated namespace: ' + templateString)
		const tpl = pug.compile('| ' + templateString)
		this.templates.push(tpl)
	}

	async getKubernetesNamespaces () {
		if (!this.k8sClient) return []

		try {
			const response = await this.k8sClient.listNamespace()
			return response.body.items.map(namespace => namespace.metadata.name)
		} catch (err) {
			console.error('Unable to get list of namespaces from K8s API:', err)
			return []
		}
	}

	async getForUser(username) {
		const staticNamespacesForUser = Array.from(this.static.entries())
			.filter(([namespace, users]) => users.length == 0 || users.includes(username))
			.map(([namespace, users]) => namespace)
		const templatedNamespacesForUser = this.templates.map(tpl => tpl({ username: username }))

		const allNamespacesForUser = staticNamespacesForUser.concat(templatedNamespacesForUser).sort()

		const k8sNamespaces = await this.getKubernetesNamespaces()

		const allNamespacesForUserThatExist = allNamespacesForUser.filter(namespace => k8sNamespaces.length == 0 || k8sNamespaces.includes(namespace))
		return allNamespacesForUserThatExist
	}

}

module.exports = NamespaceLookup
