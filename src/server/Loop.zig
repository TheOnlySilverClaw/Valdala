const color = @import("color");

const Simulation = @import("simulation").Simulation;
const Connector = @import("Connector.zig");

const Message = @import("protocol").server.Message;

const Self = @This();

simulation: *Simulation,
connector: *Connector,
running: bool,

pub fn init(simulation: *Simulation, connector: *Connector) Self {
    return .{
        .simulation = simulation,
        .connector = connector,
        .running = false
    };
}

pub fn start(self: *Self) !void {
    
    self.running = true;

    self.simulation.start();

    while(self.running) {
        try self.simulation.tick();
        
        try self.connector.broadcast(color.RGB.Compact, .{
            .header = .sky_color,
            .body = &self.simulation.world.sky_color.compact()
        });
    }
}

pub fn stop(self: *Self) void {
    self.running = false;
}