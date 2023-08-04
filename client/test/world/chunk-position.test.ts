import {expect, test} from "vitest"
import {ChunkPosition} from "../../src/world/chunk-position"
import { Vector3 } from "babylonjs"
import { CHUNK_SIZE_X, CHUNK_SIZE_Y, CHUNK_SIZE_Z } from "../../src/world/constants"

test("world origin", () => {
    
    const cp = ChunkPosition.fromWorldPosition(Vector3.Zero())
    
    expect(cp.x).toBe(0)
    expect(cp.y).toBe(0)
    expect(cp.z).toBe(0)
})

test("positive offset smaller than chunk size", () => {
    
    const cp = ChunkPosition.fromWorldPosition(new Vector3(1, CHUNK_SIZE_Y / 2, CHUNK_SIZE_Z - 1))
    
    expect(cp.x).toBe(0)
    expect(cp.y).toBe(0)
    expect(cp.z).toBe(0)
})

test("positive offset greater than chunk size", () => {
    
    const cp = ChunkPosition.fromWorldPosition(
        new Vector3(CHUNK_SIZE_X + 1, CHUNK_SIZE_Y * 1.5, CHUNK_SIZE_Z * 2 - 1))
    
    expect(cp.x).toBe(1)
    expect(cp.y).toBe(1)
    expect(cp.z).toBe(1)
})

// chunks corners are aligned around 0/0/0, so negative positions are always at least at -1 chunk positions

test("negative offset smaller than chunk size", () => {
    
    const cp = ChunkPosition.fromWorldPosition(
        new Vector3(-1, -CHUNK_SIZE_Y * 0.5, -CHUNK_SIZE_Z + 1))

    expect(cp.x).toBe(-1)
    expect(cp.y).toBe(-1)
    expect(cp.z).toBe(-1)
})

test("negative offset greater than chunk size", () => {
    
    const cp = ChunkPosition.fromWorldPosition(
        new Vector3(-CHUNK_SIZE_X -1, -CHUNK_SIZE_Y * 1.5, -CHUNK_SIZE_Z * 2 + 1))
    
    expect(cp.x).toBe(-2)
    expect(cp.y).toBe(-2)
    expect(cp.z).toBe(-2)
})

test("chunk position equality", () => {
    
    const cp1 = ChunkPosition.fromWorldPosition(Vector3.Zero())
    const cp2 = ChunkPosition.fromWorldPosition(new Vector3(1, CHUNK_SIZE_Y / 2, CHUNK_SIZE_Z - 1))
    
    expect(cp1).toEqual(cp2)
})