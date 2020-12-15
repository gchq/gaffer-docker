
const fs = require('fs')
const yaml = require('js-yaml')

const DEFAULT_CONFIG_FILE_PATH = 'conf/profiles.yaml'

class ProfileList {

	constructor(configFilePath) {
		this.list = []
		this.lookup = {}
		this.loadConfigFile(configFilePath || DEFAULT_CONFIG_FILE_PATH)
	}

	loadConfigFile(filePath) {
		if (fs.existsSync(filePath)) {
			const config = yaml.safeLoad(fs.readFileSync(filePath, 'utf8'))
			// console.log(JSON.stringify(config, null, 2))

			this.list = config
			config.forEach(profile => {
				this.lookup[profile.slug] = profile
			})
		}
	}

	getAll() {
		return this.list
	}

	getLookup() {
		return this.lookup
	}

	getForSlug(slug) {
		return this.lookup[slug]
	}

}

module.exports = ProfileList
