fn A(comptime T: type) type {
    
    return struct {
        fn ping(self: @This(), other: B(T)) void {
            _ = self;
            _ = other;
        }
    };
}

fn B(comptime T: type) type {

    return struct {
        fn pong(self: @This(), other: A(T)) void {
            _ = self;
            _ = other;
        }
    };
}

test "circular types" {

    const a = A(f32){};
    const b = B(f32){};
    a.ping(b);
    b.pong(a);
}