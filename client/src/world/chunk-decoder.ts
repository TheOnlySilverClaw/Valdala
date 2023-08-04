import { BlockType } from "./block-type";

const ID_BYTE_SIZE = 2

export class ChunkDecoder {


    constructor(private readonly blockTypes: BlockType[]) {

    }

    decode(bytes: Uint8Array): Array<BlockType | undefined> {
        
        const view = new DataView(bytes.buffer)

        const amount = bytes.length / ID_BYTE_SIZE
        const blockTypes: BlockType[] = new Array(amount)

        for(let i = 0; i < amount; i++) {
            const id = view.getUint16(i * ID_BYTE_SIZE)
            if(this.blockTypes.length <= id) {
                throw new Error("Undefined block ID: " + id)
            }
            const type = this.blockTypes[id]
            blockTypes[i] = type
        }

        return blockTypes
    }
}