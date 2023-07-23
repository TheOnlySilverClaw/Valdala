use serde::Serialize;

#[derive(Serialize)]
struct Chunk {
    position: Vector3<u8>,
    // note: Serde currently doesn't support large arrays:
    // https://github.com/serde-rs/serde/issues/1937
    blocks: Vec<u16>
}