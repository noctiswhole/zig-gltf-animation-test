const Renderer = @This();
const Framebuffer = @import("Framebuffer.zig");
const Texture = @import("Texture.zig");
const Shader = @import("Shader.zig");
const VertexBuffer = @import("VertexBuffer.zig");
const Mesh = @import("data.zig").Mesh;
const Logger = @import("../../io/Logger.zig").makeLogger("Renderer");
const std = @import("std");
const gl = @import("gl");
framebuffer: Framebuffer,
texture: Texture,
shader: Shader,
vertex_buffer: VertexBuffer,
triangle_count: usize = 0,

pub fn init(allocator: std.mem.Allocator, width: usize, height: usize) !Renderer {
    // _ = width;
    // _ = height;
    const framebuffer = try Framebuffer.init(width, height);
    Logger.log("Framebuffer initialized");
    const texture = try Texture.texture_from_file("resources/crate.png");
    Logger.log("Texture initialized");
    const shader = try Shader.init(allocator, "resources/shaders/basic.vert", "resources/shaders/basic.frag");
    Logger.log("Shader initialized");
    const vertex_buffer = VertexBuffer.init();
    Logger.log("VertexBuffer initialized");
    return .{
        .framebuffer = framebuffer,
        .texture = texture,
        .shader = shader,
        .vertex_buffer = vertex_buffer,
    };
}

pub fn deinit(self: Renderer) void {
    // _ = self;
    self.texture.deinit();
    self.shader.deinit();
    self.framebuffer.deinit();
    self.vertex_buffer.deinit();

}

pub fn upload_data(self: *Renderer, mesh: Mesh) void {
    self.triangle_count = mesh.items.len / 3;
    self.vertex_buffer.upload_data(mesh);
}

pub fn draw(self: Renderer) void {
    self.framebuffer.bind();
    defer self.framebuffer.unbind();
    gl.clearColor(0.1, 0.1, 0.1, 1);
    gl.clearDepth(1.0);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    gl.enable(gl.CULL_FACE);
    gl.enable(gl.DEPTH_TEST);

    self.shader.use();
    self.texture.bind();
    defer self.texture.unbind();
    self.vertex_buffer.bind();
    defer self.vertex_buffer.unbind();

    self.vertex_buffer.draw(gl.TRIANGLES, 0, self.triangle_count * 3);

    self.framebuffer.draw_to_screen();
}