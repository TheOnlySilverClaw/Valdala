import { Overlay } from "./overlay"
import { Renderer } from "./renderer"
import { ChunkLoader } from "./chunk-loader"

const canvasElement = document.getElementById("canvas") as HTMLCanvasElement
const overlayElement = document.getElementById("overlay")!

const renderer = new Renderer(canvasElement)
new Overlay(overlayElement, renderer)

renderer.render()

