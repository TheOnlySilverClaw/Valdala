import {expect, test} from "vitest"
import { BlockType } from "../../src/world/block-type"
import { ChunkDecoder } from "../../src/world/chunk-decoder"

test("decode valid blocks", () => {

    const blockTypes: BlockType[] = [
       { id: "air" },
       { id: "stone"}
    ]

    const decoder = new ChunkDecoder(blockTypes)

    const bytes = new Uint8Array([
        0, 1,
        0, 0
    ])

    const decoded = decoder.decode(bytes)
    
    expect(decoded.length).toBe(2)
    expect(decoded[0]!.id).toBe("stone")
    expect(decoded[1]!.id).toBe("air")

})


test("decode undefined blocks", () => {

    const blockTypes: BlockType[] = [
       { id: "air" },
       { id: "stone"}
    ]

    const decoder = new ChunkDecoder(blockTypes)

    const bytes = new Uint8Array([
        0, 2
    ])

    expect(() => decoder.decode(bytes)).toThrowError("Undefined block ID: 2")
})