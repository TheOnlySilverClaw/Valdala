import { StandardMaterial, Vector3 } from "babylonjs"
import { Overlay } from "./overlay"
import { Renderer } from "./renderer"

const canvasElement = document.getElementById("canvas") as HTMLCanvasElement
const overlayElement = document.getElementById("overlay")!

const renderer = new Renderer(canvasElement)
const overlay = new Overlay(overlayElement, renderer)

renderer.render()

