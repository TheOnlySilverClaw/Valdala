export class ChunkLoader {

    constructor(private readonly endpoint: string) {

    }

    fetchChunk(x: number, y: number, z: number) {
        fetch(this.endpoint).then(r => console.log(r))
    }
}