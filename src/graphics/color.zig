pub fn Color(T: type) type {
    
    return struct {

        red: T,
        green: T,
        blue: T,
        alpha: T,

        const Self = @This();

        pub fn rgb(red: T, green: T, blue: T) Self {
            return .{
                .red = red,
                .green = green,
                .blue = blue,
                .alpha = 1
            };
        }

        pub fn rgba(red: T, green: T, blue: T, alpha: T) Self {
            return .{
                .red = red,
                .green = green,
                .blue = blue,
                .alpha = alpha
            };
        }
    };
}