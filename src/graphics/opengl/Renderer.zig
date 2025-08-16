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
const sdl3 = @import("sdl3");
const zalgebra = @import("zalgebra");
const RenderData = data.RenderData;
const Mat4 = zalgebra.Mat4;
const Vec3 = zalgebra.Vec3;
const math = std.math;
const DEFAULT_FOV: i32 = 90;

framebuffer: Framebuffer,
texture: Texture,
shader: Shader,
shader_changed: Shader,
vertex_buffer: VertexBuffer,
uniform_buffer: UniformBuffer,
is_shader_swap: bool = false,
render_data: RenderData,
projection_matrix: Mat4,
view_matrix: Mat4 = zalgebra.lookAt(Vec3.new(3, 3, 3), Vec3.new(0, 0, 0), Vec3.new(0, 1, 0)),

pub fn init(allocator: std.mem.Allocator, width: usize, height: usize) !Renderer {
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

    const render_data: RenderData = .{
        .width = width,
        .height = height,
        .triangle_count = 0,
        .field_of_view = DEFAULT_FOV,
    };
    return .{
        .framebuffer = framebuffer,
        .texture = texture,
        .shader = shader,
        .vertex_buffer = vertex_buffer,
        .uniform_buffer = uniform_buffer,
        .shader_changed = shader_changed,
        .projection_matrix = generate_projection_matrix(width, height),
        .render_data = render_data,
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
    self.render_data.triangle_count = mesh.items.len / 3;
    self.vertex_buffer.upload_data(mesh);
}

pub fn set_size(self: *Renderer, width: usize, height: usize) !void {
    if (width == 0 or height == 0) {
        return;
    }

    try self.framebuffer.resize(width, height);
    self.render_data.width = width;
    self.render_data.height = height;
    self.projection_matrix = generate_projection_matrix(width, height);
    gl.viewport(0, 0, @intCast(width), @intCast(height));
}

pub fn update(self: *Renderer, frame_capper: sdl3.extras.FramerateCapper(f32)) void {
    self.render_data.ticks = frame_capper.frame_num;
    self.render_data.frame_time = frame_capper.dt;
    self.render_data.fps = frame_capper.getObservedFps();
}

pub fn draw(self: Renderer) void {
    self.framebuffer.bind();
    defer self.framebuffer.unbind();
    gl.clearColor(0.1, 0.1, 0.1, 1);
    gl.clearDepth(1.0);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    gl.enable(gl.CULL_FACE);
    gl.enable(gl.DEPTH_TEST);

    var model: Mat4 = Mat4.identity();
    const angle: f32 = @floatFromInt(self.render_data.ticks);
    if (self.is_shader_swap) {
        model = model.rotate(angle, Vec3.new(0, 0, 1));
        self.shader_changed.use();
    } else {
        model = model.rotate(-angle, Vec3.new(0, 0, 1));
        self.shader.use();
    }
    self.uniform_buffer.upload_data(self.view_matrix.mul(model), self.projection_matrix);

    self.texture.bind();
    defer self.texture.unbind();
    self.vertex_buffer.bind();
    defer self.vertex_buffer.unbind();

    self.vertex_buffer.draw(gl.TRIANGLES, 0, self.render_data.triangle_count * 3);

    self.framebuffer.draw_to_screen();
}

pub fn shader_swap(self: *Renderer) void {
    self.is_shader_swap = !self.is_shader_swap;
}