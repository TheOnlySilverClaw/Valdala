import std::io;

import log;
import graphics;

fn void main() {


    ConsoleLogger log = { DEBUG, io::stderr() };

    log.info("launch");

    if(catch error = start()) {
        log.fatal("unexpected error", &error);
    }

    log.info("shutdown");
}

fn void! start() {

    graphics::showWindow(1000, 800, "Valdala")!;
}
