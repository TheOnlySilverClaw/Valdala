import { StandardMaterial, Vector3 } from "babylonjs"
import { Overlay } from "./overlay"
import { Renderer } from "./renderer"
import { ChunkLoader } from "./chunk-loader"

const canvasElement = document.getElementById("canvas") as HTMLCanvasElement
const overlayElement = document.getElementById("overlay")!

const renderer = new Renderer(canvasElement)
const overlay = new Overlay(overlayElement, renderer)

renderer.render()

const chunkLoader = new ChunkLoader("http://localhost:8080")
chunkLoader.fetchChunk(0, 0, 0)
