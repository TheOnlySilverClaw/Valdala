pub fn Rectangle(T: type) type {
    return struct {
        x: T,
        y: T,
        width: T,
        height: T
    };
}