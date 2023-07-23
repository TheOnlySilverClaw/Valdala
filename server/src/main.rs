use std::{collections::HashMap, sync::Arc};

use anyhow::Result;
use nalgebra::Vector3;
use serde::Serialize;

mod server;
mod world;

fn main() -> Result<()>{
    
    tracing_subscriber::fmt().init();

    let async_runtime = tokio::runtime::Builder::new_current_thread().enable_all().build()?;
    
    let mut webserver = server::WebServer::new("127.0.0.1:8080");
    async_runtime.block_on(webserver.start());

    Ok(())
}
