const esbuild = require("esbuild")
const ElmPlugin = require("esbuild-plugin-elm")

require('esbuild').build({
	entryPoints: ['src/index.js'],
	// Warning: bundle does not cleanup unused files.
	bundle: true,
	outdir: 'dist',
	watch: process.argv.includes("--watch"),
	plugins: [
		ElmPlugin({
			debug: true,
			clearOnWatch: true
		})
	]
}).catch(e => (console.error(e), process.exit(1)))