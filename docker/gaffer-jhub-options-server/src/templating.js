
const fs = require('fs')
const path = require('path')

const renderFilesInDirectory = async (dirPath, replacements) => {
	const dir = await fs.promises.opendir(dirPath)

	const files = []
	for await (const entry of dir) {
		if (entry.isFile()) {
			files.push({
				name: entry.name,
				contents: renderFile(path.join(dirPath, entry.name), replacements)
			})
		}
	}

	const renderedFiles = await Promise.all(files.map(async file => {
		const renderedContents = await file.contents
		file.contents = renderedContents
		return file
	}))

	return renderedFiles
}

const renderFile = async (filePath, replacements) => {
	const contents = await fs.promises.readFile(filePath)
	return renderTemplate(contents.toString(), replacements)
}

const renderTemplate = (tpl, replacements) => {
	return Object.entries(replacements)
	.reduce((tpl, [match, replace]) => tpl.replace(new RegExp('{{' + match + '}}', 'g'), replace), tpl)
}

module.exports = {
	renderFilesInDirectory,
	renderFile,
	renderTemplate
}
