pub fn Point2D(T: type) type {
    return packed struct {
        x: T,
        y: T
    };
}