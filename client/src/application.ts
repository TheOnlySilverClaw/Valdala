import {ServerInfo } from "@yamc/types"

const applicationElement = document.getElementById("application")!


const response = await fetch("http://localhost:8080")
const serverInfo = await response.json() as ServerInfo

applicationElement.innerText = serverInfo.name + " v" + serverInfo.version
