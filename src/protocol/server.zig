const color = @import("color");

pub const Header = enum(u8) {
    connect,
    disconnect,
    shutdown,
    sky_color
};

pub fn Message(T: type) type {
    return struct {
        header: Header,
        body: *const T
    };
}