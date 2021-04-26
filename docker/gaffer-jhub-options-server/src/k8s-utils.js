
const k8s = require('@kubernetes/client-node')
const templating = require('./templating.js')

class K8sUtils {

	constructor(kubeConfig) {
		this.client = k8s.KubernetesObjectApi.makeApiClient(kubeConfig)
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

}

module.exports = K8sUtils
