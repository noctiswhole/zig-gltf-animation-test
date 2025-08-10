const Renderer = @This();
const Framebuffer = @import("Framebuffer.zig");
const Texture = @import("Texture.zig");
const gl = @import("gl");
framebuffer: Framebuffer,
texture: Texture,

pub fn init(width: usize, height: usize) !Renderer {
    // _ = width;
    // _ = height;
    const framebuffer = try Framebuffer.init(width, height);
    const texture = try Texture.texture_from_file("resources/crate.png");
    return .{
        .framebuffer = framebuffer,
        .texture = texture,
    };
}

pub fn deinit(self: Renderer) void {
    // _ = self;
    self.texture.deinit();
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