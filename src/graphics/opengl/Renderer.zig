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

pub fn upload_data(self: Renderer, mesh: Mesh) void {
    _ = self;
    _ = mesh;

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