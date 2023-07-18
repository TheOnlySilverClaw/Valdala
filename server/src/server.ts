import { Hono } from "hono"
import { cors } from "hono-middleware"
import { join } from "path"
import { parse } from "toml"
import { ServerInfo } from "types"

interface ServerSettings {
	hostname: string
	port: number
}


/** Path to the server instance directory */
const INSTANCE_PATH = Deno.args[0]!

function loadServerSettings(): ServerSettings {

	// TODO actually validate
	return parse(Deno.readTextFileSync(join(INSTANCE_PATH, "server.toml"))) as unknown as ServerSettings
}

function startWebServer(settings: ServerSettings, info: ServerInfo) {
	
	const {hostname, port } = settings

	const application = new Hono()
	application.use("*", cors({origin: "*"}))
	application.get("/", (context) => context.json(info))

	Deno.serve({hostname, port}, application.fetch)
}

const serverSettings = loadServerSettings()
const serverInfo: ServerInfo = { name: "development", version: "0.0.1" }

startWebServer(serverSettings, serverInfo)
