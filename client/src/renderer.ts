import { ArcRotateCamera, Color3, DirectionalLight, Engine, Mesh, MeshBuilder, Scene, StandardMaterial, Vector3 } from "babylonjs"

const WORLD_SIZE = 256

export class Renderer {

    private readonly engine: Engine
    private readonly scene: Scene
    private readonly camera: ArcRotateCamera
    private readonly sunLight: DirectionalLight

    constructor(private readonly canvas: HTMLCanvasElement) {
        
        this.engine = new Engine(canvas, true)
        this.scene = new Scene(this.engine)
        
        // easier for mesh building
        this.camera = new ArcRotateCamera("camera", 1, 1, WORLD_SIZE + 10, new Vector3(WORLD_SIZE / 2, 0, WORLD_SIZE / 2), this.scene)
        // this.camera.setTarget(Vector3.Zero())
        this.camera.attachControl(this.canvas, false)
        this.sunLight = new DirectionalLight("sun-light", new Vector3(0, -1, 0), this.scene)
        this.sunLight.diffuse = Color3.Yellow()

        window.addEventListener("resize", () => this.engine.resize())

        this.setupScene()
    }

    get fps(): number {
        return this.engine.getFps()
    }

    get cameraPosition(): Vector3 {
        return this.camera.position
    }

    get cameraRotation(): Vector3 {
        return this.camera.rotation
    }

    get meshCount(): number {
        return this.scene.meshes.length
    }

    // TODO load actual world data
    setupScene() {

        const material = new StandardMaterial("block-material", this.scene)
        material.diffuseColor = Color3.Green()
        const blockTemplate = MeshBuilder.CreateBox("block")
        blockTemplate.material = material
        // template gets added to scene automatically, let's not
        this.scene.removeMesh(blockTemplate)

        const blockMeshes = []
        for(let x = 0; x < WORLD_SIZE; x++) {
            for(let z = 0; z < WORLD_SIZE; z++) {
                const y = Math.round(Math.random() * 6)
                const blockMesh = blockTemplate.clone()
                this.scene.removeMesh(blockMesh)
                blockMesh.position = new Vector3(x, y, z)
                blockMeshes.push(blockMesh)
            }
        }

        const chunkMesh = Mesh.MergeMeshes(blockMeshes, true, true, undefined, false, false)!
        
        // this.scene.addMesh(chunkMesh)
    }

    render() {
        this.engine.runRenderLoop(() => {
            this.scene.render()
        })
    }
}