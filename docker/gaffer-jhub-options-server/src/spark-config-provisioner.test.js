
const k8s = require('@kubernetes/client-node')
const SparkConfigProvisioner = require('./spark-config-provisioner.js')

const kubeConfig = new k8s.KubeConfig()
kubeConfig.loadFromDefault()

const spark = new SparkConfigProvisioner(kubeConfig)

test('can provision Spark service', async () => {
	await spark.provisionDriverService("spark-test-svc", "default", "user1", "server1", 80)
})

test('can provision Spark ingress', async () => {
	await spark.provisionDriverIngress("spark-test-ingress", "default", "localhost", "/", "spark-test-svc", 80, "user1", "server1")
})
