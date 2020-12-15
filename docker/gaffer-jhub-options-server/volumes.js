
const K8sWatcher = require('./k8s-watcher')

const COMPONENT_NAME = 'notebook-volume'

class PersistentVolumeClaimLookup {

	constructor(kubeConfig) {
		this.pvcs = new Map()

		this.watcher = new K8sWatcher(kubeConfig, '/api/v1/persistentvolumeclaims', {
			labelSelector: 'app.kubernetes.io/name=jupyterhub,app.kubernetes.io/component=' + COMPONENT_NAME
		})
		this.watcher.on('RESET', () => this.pvcs.clear())
		this.watcher.on('ADDED', this.handleVolumeAdded.bind(this))
		this.watcher.on('MODIFIED', this.handleVolumeAdded.bind(this))
		this.watcher.on('DELETED', this.handleVolumeRemoved.bind(this))
	}

	handleVolumeAdded(pvc) {
		const volume = {
			id: pvc.metadata.namespace + ':' + pvc.metadata.name,
			name: pvc.metadata.name,
			namespace: pvc.metadata.namespace,
			username: pvc.metadata.labels['hub.jupyter.org/username'],
			servername: pvc.metadata.labels['hub.jupyter.org/servername'],
			volumeName: pvc.metadata.labels['hub.jupyter.org/volume-name']
		}

		console.log('Adding volume called ' + volume.volumeName + ' for ' + volume.username + ' in ' + volume.namespace)

		if (!this.pvcs.has(volume.username)) {
			this.pvcs.set(volume.username, new Map())
		}
		this.pvcs.get(volume.username).set(volume.id, volume)
	}

	handleVolumeRemoved(pvc) {
		const id = pvc.metadata.namespace + ':' + pvc.metadata.name
		const username = pvc.metadata.labels['hub.jupyter.org/username']
		const volumeName = pvc.metadata.labels['hub.jupyter.org/volume-name']
		console.log('Removing volume called ' + volumeName + ' for ' + username + ' in ' + pvc.metadata.namespace)
		this.pvcs.get(username).delete(id)
	}

	getForUser(username, namespaces) {
		if (!this.pvcs.has(username)) return []
		return new Map(Array.from(this.pvcs.get(username).entries()).filter(([id, pvc]) => namespaces.includes(pvc.namespace)))
	}

	getLabels(username, servername, volumeName) {
		return {
			'app.kubernetes.io/name': 'jupyterhub',
			'app.kubernetes.io/component': COMPONENT_NAME,
			'hub.jupyter.org/username': username,
			'hub.jupyter.org/servername': servername,
			'hub.jupyter.org/volume-name': volumeName
		}
	}

	getPodSpecForExistingVolume(volumeId, username, servername) {
		const volume = this.pvcs.get(username).get(volumeId)
		return {
			pvc_name: volume.name,
			storage_extra_labels: this.getLabels(username, servername, volume.volumeName)
		}
	}

	getPodSpecConfigForNewVolume(volumeName, username, servername) {
		return {
			storage_extra_labels: this.getLabels(username, servername, volumeName)
		}
	}

}

module.exports = PersistentVolumeClaimLookup
