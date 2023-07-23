
use salvo::prelude::*;
use tokio::net::ToSocketAddrs;

mod handlers;

pub struct WebServer {
}

impl WebServer {
    
    pub fn new<T: ToSocketAddrs + Send>(address: T) -> WebServer {
        TcpListener::new(address);
        return WebServer{}
    }

    pub async fn start(&mut self) {
        
    }
}

