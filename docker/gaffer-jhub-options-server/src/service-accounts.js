
const arnparse = require('aws-arn-parser')
const K8sWatcher = require('./k8s-watcher')

const DEFAULT_SERVICE_ACCOUNT_LABEL = 'hub.jupyter.org/notebook-service-account'
const DEFAULT_AWS_IAM_ROLE_ANNOTATION = 'eks.amazonaws.com/role-arn'
const DEFAULT_USER_ACCESS_ANNOTATION = 'hub.jupyter.org/users'

class K8sServiceAccountDirectory {

	constructor(kubeConfig, serviceAccountLabel, awsIamRoleAnnotation, userAccessAnnotation) {
		this.serviceAccountLabel = serviceAccountLabel || DEFAULT_SERVICE_ACCOUNT_LABEL
		this.awsIamRoleAnnotation = awsIamRoleAnnotation || DEFAULT_AWS_IAM_ROLE_ANNOTATION
		this.userAccessAnnotation = userAccessAnnotation || DEFAULT_USER_ACCESS_ANNOTATION

		this.serviceAccounts = new Map()

		this.watcher = new K8sWatcher(kubeConfig, '/api/v1/serviceaccounts', {
			labelSelector: this.serviceAccountLabel
		})
		this.watcher.on('RESET', () => this.serviceAccounts = new Map())
		this.watcher.on('ADDED', this.add.bind(this))
		this.watcher.on('MODIFIED', this.add.bind(this))
		this.watcher.on('DELETED', this.remove.bind(this))
	}

	add(serviceAccount) {
		const id = serviceAccount.metadata.namespace + ':' + serviceAccount.metadata.name
		let awsIamRoleArn = null
		let awsIamRoleName = null
		let users = []

		if ('annotations' in serviceAccount.metadata) {
			if (this.awsIamRoleAnnotation in serviceAccount.metadata.annotations) {
				awsIamRoleArn = serviceAccount.metadata.annotations[this.awsIamRoleAnnotation]

				const arn = arnparse(awsIamRoleArn)
				const resourceInfo = arn.relativeId.split('/', 2)
				if (resourceInfo.length == 2) {
					const resourceType = resourceInfo[0]
					const resourceId = resourceInfo[1]
					if (resourceType == 'role') {
						awsIamRoleName = resourceId
					}
				}
			}

			if (this.userAccessAnnotation in serviceAccount.metadata.annotations) {
				users = serviceAccount.metadata.annotations[this.userAccessAnnotation].split(',')
			}
		}

		const info = {
			id: id,
			namespace: serviceAccount.metadata.namespace,
			name: serviceAccount.metadata.name,
			iamRole: {
				arn: awsIamRoleArn,
				name: awsIamRoleName
			},
			users: users
		}
		console.log('Added K8s Service Account: ' + id)
		this.serviceAccounts.set(id, info)
	}

	remove(serviceAccount) {
		const id = serviceAccount.metadata.namespace + ':' + serviceAccount.metadata.name
		console.log('Removed K8s Service Account: ' + id)
		this.serviceAccounts.delete(id)
	}

	getForUser(username, namespaces) {
		return new Map(Array.from(this.serviceAccounts.entries())
			.filter(([id, serviceAccount]) =>
				namespaces.includes(serviceAccount.namespace) &&
				(
					serviceAccount.users.length == 0 ||
					serviceAccount.users.includes(username)
				)
			)
		)
	}

	getPodSpecConfig(id) {
		const serviceAccount = this.serviceAccounts.get(id)
		if (!serviceAccount) throw 'Service Account not found: ' + id

		const config = {
			'serviceAccount': serviceAccount.name
		}
		return config
	}

}

module.exports = K8sServiceAccountDirectory
