use std::sync::Arc;

use salvo::prelude::*;

use crate::world::chunk_generator::ChunkGenerator;

struct ChunkHandler {
    generator: Arc<ChunkGenerator>
}

#[async_trait]
impl Handler for ChunkHandler {

    async fn handle(&self, request: &mut Request, _: &mut Depot, response: &mut Response, _: &mut FlowCtrl) {

        
    }
}