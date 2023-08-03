import { ArcRotateCamera, Color3, Color4, DirectionalLight, Engine, HemisphericLight, Mesh, MeshBuilder, Scene, StandardMaterial, Vector3 } from "babylonjs"

const CHUNKS_COUNT = 2
const CHUNK_SIZE = 16
const WORLD_SIZE = CHUNKS_COUNT * CHUNK_SIZE
// how often blocks types are mixed
const BLOCK_TYPE_INTERVAL = 7 * (CHUNK_SIZE / 2 - 1)

export class Renderer {

    private readonly engine: Engine
    private readonly scene: Scene
    private readonly camera: ArcRotateCamera
    private readonly sunLight: DirectionalLight
    private readonly ambientLight: HemisphericLight
    private readonly playerMesh: Mesh

    #blockCount: number

    constructor(private readonly canvas: HTMLCanvasElement) {
        
        this.engine = new Engine(canvas, true)
        this.scene = new Scene(this.engine)
        this.scene.clearColor = new Color4(0.53, 0.81, 0.92, 1.0) // sky blue
        
        // easier for mesh building
        this.camera = new ArcRotateCamera("camera", 1, 1, WORLD_SIZE + 10, new Vector3(WORLD_SIZE / 2, 0, WORLD_SIZE / 2), this.scene)
        // this.camera.setTarget(Vector3.Zero())
        this.camera.attachControl(this.canvas, false)
        this.sunLight = new DirectionalLight("sun-light", new Vector3(0.2, -1, 0.2), this.scene)
        this.sunLight.diffuse = new Color3(0.945, 0.855, 0.64) // sun light
        this.sunLight.intensity = 0.5

        this.ambientLight = new HemisphericLight("ambient-light", Vector3.Up(), this.scene)
        this.ambientLight.diffuse = Color3.White()
        this.ambientLight.groundColor = Color3.Black()
        this.ambientLight.intensity = 0.6

        this.playerMesh = MeshBuilder.CreateCapsule("player", {height: 2, radius: 0.4})
        const playerMaterial = new StandardMaterial("player-material")
        playerMaterial.diffuseColor = Color3.Black()
        this.playerMesh.material = playerMaterial

        window.addEventListener("resize", () => this.engine.resize())

        window.addEventListener("keydown", (event) => {
            switch(event.key) {
            case "a": { this.playerMesh.position.x += 1; break}
            case "d": { this.playerMesh.position.x -= 1; break}
            case "w": { this.playerMesh.position.z -= 1; break}
            case "s": { this.playerMesh.position.z += 1; break}
            }
        })

        this.#blockCount = 0
        // this.setupScene()
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

    get playerPosition(): Vector3 {
        return this.playerMesh.position
    }

    get meshCount(): number {
        return this.scene.meshes.length
    }

    get blockCount(): number {
        return this.#blockCount
    }

 

    // TODO load actual world data
    setupScene() {

        
        const material1 = new StandardMaterial("block-material-01", this.scene)
        const material2 = new StandardMaterial("block-material-02", this.scene)
        const material3 = new StandardMaterial("block-material-03", this.scene)
        const material4 = new StandardMaterial("block-material-04", this.scene)

        material1.diffuseColor = Color3.Green()
        material2.diffuseColor = Color3.Blue()
        material3.diffuseColor = Color3.Red()
        material4.diffuseColor = Color3.Purple()

        const blockTemplate1 = MeshBuilder.CreateBox("block1")
        const blockTemplate2 = MeshBuilder.CreateBox("block2")
        const blockTemplate3 = MeshBuilder.CreateBox("block3")
        const blockTemplate4 = MeshBuilder.CreateBox("block4")

        blockTemplate1.material = material1
        blockTemplate2.material = material2
        blockTemplate3.material = material3
        blockTemplate4.material = material4

        
        const baseHeight = CHUNK_SIZE / 4

        let height = 0.5

        const templates = [
            blockTemplate1,
            blockTemplate2,
            blockTemplate3,
            blockTemplate4
        ]

        const randomTemplate = () => {
            const r = Math.floor(Math.random() * templates.length)
            return templates[r]
        }

        // template gets added to scene automatically, let's not
        templates.forEach(t => this.scene.removeMesh(t))

        let blockTypeCount = 0
        let blockTemplate = randomTemplate()
        

        for(let chunkX = 0; chunkX < CHUNKS_COUNT; chunkX++) {
            height = Math.min(1.0, Math.max(0.0, height + 0.1 * (Math.random() - 0.5)))
            for(let chunkZ = 0; chunkZ < CHUNKS_COUNT; chunkZ++) {
                console.debug(`chunk ${chunkX} ${chunkZ}`)
                const blockMeshes = []
                for(let x = 0; x < CHUNK_SIZE; x++) {
                    for(let z = 0; z < CHUNK_SIZE; z++) {
                        const height = Math.random() + Math.random()
                        const blockHeight = baseHeight + baseHeight * height
                        for(let y = 0; y < blockHeight; y++) {
                            if(blockTypeCount > BLOCK_TYPE_INTERVAL) {
                                blockTypeCount = 0
                                blockTemplate = randomTemplate()
                            } else {
                                blockTypeCount++
                            }
                            const blockMesh = blockTemplate.clone()
                            this.scene.removeMesh(blockMesh)
                            blockMesh.position = new Vector3(x, y, z)
                            blockMeshes.push(blockMesh)
                            this.#blockCount++
                        }                     
                    }
                }
        
                for(let t = 0; t < templates.length; t++) {
                    const material = templates[t].material
                    const filtered = blockMeshes.filter(m => m.material!.id == material!.id)

                    if(filtered.length > 0) {

                        const chunkMesh = Mesh.MergeMeshes(filtered, true, true, undefined, false, false)!
                        chunkMesh.position.x = chunkX * CHUNK_SIZE
                        chunkMesh.position.z = chunkZ * CHUNK_SIZE
                    }
                }
                
            }
        }
    }

    render() {
        this.engine.runRenderLoop(() => {
            this.scene.render()
        })
    }
}