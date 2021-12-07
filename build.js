const { build } = require("esbuild")
const ElmPlugin = require("esbuild-plugin-elm")
const devServer = require("esbuild-dev-server")
const { dsvPlugin } = require("esbuild-plugin-dsv")

devServer.start(
	build({
		entryPoints: ['src/index.js'],
		// Warning: bundle does not cleanup unused files.
		bundle: true,
		outdir: 'public/js',
		incremental: true,
		plugins: [
			dsvPlugin(),
			ElmPlugin()
		],
	}).catch(e => (console.error(e), process.exit(1))),
	{
		port: "8080",
		watchDir: "src",
		index: "public/index.html",
		staticDir: "public",
		onAfterRebuild() {},
		onBeforeRebuild() {},
	}
)
