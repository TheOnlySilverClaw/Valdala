pub fn Point(T: type) type {
    return struct {
        x: T,
        y: T
    };
}