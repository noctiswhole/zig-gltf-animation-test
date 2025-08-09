const Renderer = @This();
const Framebuffer = @import("Framebuffer.zig");
const gl = @import("gl");
framebuffer: Framebuffer,

pub fn init(width: usize, height: usize) !Renderer {
    // _ = width;
    // _ = height;
    const framebuffer = try Framebuffer.init(width, height);
    return .{
        .framebuffer = framebuffer,
    };
}

pub fn deinit(self: Renderer) void {
    // _ = self;
    self.framebuffer.deinit();

}

pub fn draw(self: Renderer) void {
    self.framebuffer.bind();
    gl.clearColor(1, 1, 0, 1);
    gl.clearDepth(1.0);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    gl.enable(gl.CULL_FACE);
    gl.enable(gl.DEPTH_TEST);

    self.framebuffer.unbind();
    self.framebuffer.draw_to_screen();
}