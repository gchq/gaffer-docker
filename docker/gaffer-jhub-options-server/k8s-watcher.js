
const EventEmitter = require('events')
const k8s = require('@kubernetes/client-node')

class K8sWatcher extends EventEmitter {

	constructor(kubeConfig, url, params) {
		super()
		this.kubeConfig = kubeConfig
		this.url = url
		this.params = params || {}
		this.watch()
	}

	watch(){
		console.log('Starting watch of:', this.url, JSON.stringify(this.params))
		this.emit('RESET')
		const k8sWatch = new k8s.Watch(this.kubeConfig)
		this.watcher = k8sWatch.watch(this.url, this.params, (type, resource) => {
			// console.log(type + ': ' + JSON.stringify(resource))

			if (['ADDED', 'MODIFIED', 'DELETED'].includes(type)) {
				this.emit(type, resource)
			} else {
				throw 'Unknown event type: ' + type
			}
		}, (err) => {
			if (err) {
				console.error('Watch of', this.url, 'failed:', err)
			} else {
				setTimeout(() => this.watch(), 5000)
			}
		})
	}

}

module.exports = K8sWatcher
