const Surface = @import("surface.zig").Surface;

pub const RenderError = error {

};

pub const Renderer = struct {
    surface: *const Surface,

    pub fn render(self: *const Renderer) RenderError!void {
        self.surface.render();
    }
};