import { Renderer } from "./renderer";

export class Overlay{

    constructor(element: HTMLElement, renderer: Renderer) {

        const fpsElement = element.querySelector("#fps") as HTMLElement
        const positionElement = element.querySelector("#position") as HTMLElement
        const rotationElement = element.querySelector("#rotation") as HTMLElement
        const meshCountElement = element.querySelector("#mesh-count") as HTMLElement
        const blockCountElement = element.querySelector("#block-count") as HTMLElement

        setInterval(() => {
            fpsElement.innerText = renderer.fps.toFixed(2) + " FPS"

            const position = renderer.playerPosition
            positionElement.innerText = `position: x: ${position.x.toFixed(2)} y: ${position.y.toFixed(2)} z: ${position.z.toFixed(2)}`

            // doesn't work with arc camera?
            // const rotation = renderer.cameraRotation
            // rotationElement.innerText = `rotation: x: ${rotation.x.toFixed(2)} y: ${rotation.y.toFixed(2)} z: ${rotation.z.toFixed(2)}`

            meshCountElement.innerText = `${renderer.meshCount} meshes`
            
            blockCountElement.innerText = `${renderer.blockCount.toLocaleString("de")} blocks`
        }, 200)
    }    
}