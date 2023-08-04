import { Chunk } from "./chunk";
import { ChunkPosition } from "./chunk-position";

export class World {
    
    private readonly chunkMap: Map<ChunkPosition, Chunk>;

    constructor() {
        this.chunkMap = new Map()
        
    }

    getChunk(position: ChunkPosition): Chunk | undefined {
        return this.chunkMap.get(position)
    }
}