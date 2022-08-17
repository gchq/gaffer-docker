
const k8s = require('@kubernetes/client-node')
const templating = require('./templating.js')

class K8sUtils {

	constructor(kubeConfig) {
		this.kubeConfig = kubeConfig
		this.client = k8s.KubernetesObjectApi.makeApiClient(kubeConfig)
		this.ingressApiVersion = null
	}

	async applySpec(spec) {
		try {
			const readResponse = await this.client.read(spec)
			const currentVersion = readResponse.body

			// Resource exists, so update
			const patchResponse = await this.client.patch(spec)
			const newVersion = patchResponse.body
			return newVersion
		} catch (err) {
			if (err.statusCode == 404) {
				// Resource doesn't exist, so create
				const createReponse = await this.client.create(spec)
				const newVersion = createReponse.body
				return newVersion
			} else {
				throw err
			}
		}
	}

	async generateConfigMapSpecForDirectoryOfTemplates(name, namespace, dirPath, replacements) {
		const fileList = await templating.renderFilesInDirectory(dirPath, replacements || {})
		const fileMap = fileList.reduce((files, file) => {
			files[file.name] = file.contents
			return files
		}, {})

		const spec = {
			'apiVersion': 'v1',
			'kind': 'ConfigMap',
			'metadata': {
				'name': name,
				'namespace': namespace
			},
			'data': fileMap
		}
		return spec
	}

	async getSupportedIngressApiVersion() {
		if (this.ingressApiVersion !== null)
			return this.ingressApiVersion

		const apiClient = this.kubeConfig.makeApiClient(k8s.ApisApi)
		const apiResponse = await apiClient.getAPIVersions()
		const apiVersions = apiResponse.body.groups.flatMap(group => group.versions.map(version => version.groupVersion))

		if (apiVersions.indexOf('networking.k8s.io/v1') != -1) {
			const response = await this.kubeConfig.makeApiClient(k8s.NetworkingV1Api).getAPIResources()
			if (response.body.resources.filter(resource => resource.kind === 'Ingress').length > 0) {
				this.ingressApiVersion = 'networking.k8s.io/v1'
				return this.ingressApiVersion
			}
		}

		if (apiVersions.indexOf("networking.k8s.io/v1beta1") != -1) {
			const response = await this.kubeConfig.makeApiClient(k8s.NetworkingV1beta1Api).getAPIResources()
			if (response.body.resources.filter(resource => resource.kind === 'Ingress').length > 0) {
				this.ingressApiVersion = 'networking.k8s.io/v1beta1'
				return this.ingressApiVersion
			}
		}

		throw 'Failed to detect the API version supported by the Kubernetes cluster'
	}

	async createIngress(name, namespace, labels, host, path, serviceName, servicePort) {
		const ingressApiVersion = await this.getSupportedIngressApiVersion()
		if (ingressApiVersion === 'networking.k8s.io/v1') {
			return this.createIngressV1(name, namespace, labels, host, path, serviceName, servicePort)
		} else if (ingressApiVersion === 'networking.k8s.io/v1beta1') {
			return this.createIngressV1Beta1(name, namespace, labels, host, path, serviceName, servicePort)
		} else {
			throw `Unable to create ingress ${namespace}:${name} as support is missing for the Ingress version used by the Kubernetes cluster: ${this.ingressApiVersion}`
		}
	}

	async createIngressV1(name, namespace, labels, host, path, serviceName, servicePort) {
		const ingressPath = {
			pathType: 'ImplementationSpecific',
			backend: {
				service: {
					name: serviceName,
					port: {
						number: servicePort
					}
				}
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
			apiVersion: 'networking.k8s.io/v1',
			kind: 'Ingress',
			metadata: { name, namespace, labels },
			spec: {
				rules: [rule]
			}
		}

		const response = await this.applySpec(ingress)
		return response
	}

	async createIngressV1Beta1(name, namespace, labels, host, path, serviceName, servicePort) {
		const ingressPath = {
			backend: {
				serviceName,
				servicePort
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
			apiVersion: 'networking.k8s.io/v1beta1',
			kind: 'Ingress',
			metadata: { name, namespace, labels },
			spec: {
				rules: [rule]
			}
		}

		const response = await this.applySpec(ingress)
		return response
	}

}

module.exports = K8sUtils
