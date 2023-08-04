import { Vector3 } from "babylonjs";
import { CHUNK_SIZE_X, CHUNK_SIZE_Y, CHUNK_SIZE_Z } from "./constants";

export class ChunkPosition {

    constructor(readonly x: number, readonly y: number, readonly z: number) {}

    toWorldPosition(): Vector3 {
        return new Vector3(this.x * CHUNK_SIZE_X, this.y * CHUNK_SIZE_Y, this.z * CHUNK_SIZE_Z)
    }

    static fromWorldPosition(position: Vector3): ChunkPosition {
        
        const {x, y, z} = position
        const floor = Math.floor

        return new ChunkPosition(
            floor(x / CHUNK_SIZE_X),
            floor(y / CHUNK_SIZE_Y),
            floor(z / CHUNK_SIZE_Z)
            )
    }
}

