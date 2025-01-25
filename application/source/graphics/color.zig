pub fn Color(T: type) type {
    return extern struct {
        red: T,
        green: T,
        blue: T,
        alpha: T
    };
}