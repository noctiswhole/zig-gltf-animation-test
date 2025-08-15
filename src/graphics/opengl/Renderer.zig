const Renderer = @This();
const Framebuffer = @import("Framebuffer.zig");
const Texture = @import("Texture.zig");
const Shader = @import("Shader.zig");
const VertexBuffer = @import("VertexBuffer.zig");
const UniformBuffer = @import("UniformBuffer.zig");
const data = @import("../3d/data.zig");
const Mesh = data.Mesh;
const Logger = @import("../../io/Logger.zig").makeLogger("Renderer");
const std = @import("std");
const gl = @import("gl");
const zalgebra = @import("zalgebra");
const Mat4 = zalgebra.Mat4;
const Vec3 = zalgebra.Vec3;
const math = std.math;

framebuffer: Framebuffer,
texture: Texture,
shader: Shader,
shader_changed: Shader,
vertex_buffer: VertexBuffer,
uniform_buffer: UniformBuffer,
triangle_count: usize = 0,
is_shader_swap: bool = false,
projection_matrix: Mat4,
view_matrix: Mat4 = zalgebra.lookAt(Vec3.new(3, 3, 3), Vec3.new(0, 0, 0), Vec3.new(0, 1, 0)),

pub fn init(allocator: std.mem.Allocator, width: usize, height: usize) !Renderer {
    // _ = width;
    // _ = height;
    const framebuffer = try Framebuffer.init(width, height);
    Logger.log("Framebuffer initialized");
    const texture = try Texture.texture_from_file("resources/crate.png");
    Logger.log("Texture initialized");
    const vertex_buffer = VertexBuffer.init();
    Logger.log("VertexBuffer initialized");
    const uniform_buffer = UniformBuffer.init();
    Logger.log("UniformBuffer initialized");
    const shader = try Shader.init(allocator, "resources/shaders/basic.vert", "resources/shaders/basic.frag");
    Logger.log("Shader initialized");
    const shader_changed = try Shader.init(allocator, "resources/shaders/changed.vert", "resources/shaders/changed.frag");
    Logger.log("Shader2 initialized");
    return .{
        .framebuffer = framebuffer,
        .texture = texture,
        .shader = shader,
        .vertex_buffer = vertex_buffer,
        .uniform_buffer = uniform_buffer,
        .shader_changed = shader_changed,
        .projection_matrix = generate_projection_matrix(width, height),
    };
}

pub fn deinit(self: *Renderer) void {
    self.texture.deinit();
    self.uniform_buffer.deinit();
    self.shader.deinit();
    self.framebuffer.deinit();
    self.vertex_buffer.deinit();
}

fn generate_projection_matrix(width: usize, height: usize) Mat4 {
    // return zmath.perspectiveFovRhGl(0.25 * math.pi, @as(f32, @floatFromInt(width))/@as(f32, @floatFromInt(height)), 0.1, 20.0);
    return zalgebra.perspective(45, @as(f32, @floatFromInt(width))/@as(f32, @floatFromInt(height)), 0.1, 100.0);
}

pub fn upload_data(self: *Renderer, mesh: Mesh) void {
    self.triangle_count = mesh.items.len / 3;
    self.vertex_buffer.upload_data(mesh);
}

pub fn set_size(self: *Renderer, width: usize, height: usize) !void {
    if (width == 0 or height == 0) {
        return;
    }

    try self.framebuffer.resize(width, height);
    self.projection_matrix = generate_projection_matrix(width, height);
    gl.viewport(0, 0, @intCast(width), @intCast(height));
}

pub fn draw(self: Renderer) void {
    self.framebuffer.bind();
    defer self.framebuffer.unbind();
    gl.clearColor(0.1, 0.1, 0.1, 1);
    gl.clearDepth(1.0);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    gl.enable(gl.CULL_FACE);
    gl.enable(gl.DEPTH_TEST);

    self.uniform_buffer.upload_data(self.view_matrix, self.projection_matrix);
    if (self.is_shader_swap) {
        self.shader_changed.use();
    } else {
        self.shader.use();
    }

    self.texture.bind();
    defer self.texture.unbind();
    self.vertex_buffer.bind();
    defer self.vertex_buffer.unbind();

    self.vertex_buffer.draw(gl.TRIANGLES, 0, self.triangle_count * 3);

    self.framebuffer.draw_to_screen();
}

pub fn shader_swap(self: *Renderer) void {
    self.is_shader_swap = !self.is_shader_swap;
}