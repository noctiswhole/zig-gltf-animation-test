const Renderer = @This();
const Framebuffer = @import("Framebuffer.zig");
const Texture = @import("Texture.zig");
const Shader = @import("Shader.zig");
const VertexBuffer = @import("VertexBuffer.zig");
const UniformBuffer = @import("UniformBuffer.zig");
const Timer = @import("../../tools/Timer.zig");
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
const Camera = @import("../3d/Camera.zig");
const InputEvent = @import("../../io/InputMap.zig").InputEvent;
const math = std.math;
const DEFAULT_FOV: f32 = 90;

framebuffer: Framebuffer,
texture: Texture,
shader: Shader,
shader_changed: Shader,
vertex_buffer: VertexBuffer,
uniform_buffer: UniformBuffer,
is_shader_swap: bool = false,
render_data: RenderData,
projection_matrix: Mat4,
camera: Camera = .{},

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
        .projection_matrix = generate_projection_matrix(width, height, DEFAULT_FOV),
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

fn generate_projection_matrix(width: usize, height: usize, fov: f32) Mat4 {
    // return zmath.perspectiveFovRhGl(0.25 * math.pi, @as(f32, @floatFromInt(width))/@as(f32, @floatFromInt(height)), 0.1, 20.0);
    return zalgebra.perspective(fov, @as(f32, @floatFromInt(width))/@as(f32, @floatFromInt(height)), 0.1, 100.0);
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
    self.projection_matrix = generate_projection_matrix(width, height, self.render_data.field_of_view);
    gl.viewport(0, 0, @intCast(width), @intCast(height));
}

pub fn update(self: *Renderer, frame_capper: sdl3.extras.FramerateCapper(f32)) void {
    self.render_data.ticks = frame_capper.frame_num;
    self.render_data.frame_time = frame_capper.dt;
    self.render_data.fps = frame_capper.getObservedFps();
}

pub fn draw(self: *Renderer) void {
    self.framebuffer.bind();
    defer self.framebuffer.unbind();
    gl.clearColor(0.1, 0.1, 0.1, 1);
    gl.clearDepth(1.0);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    gl.enable(gl.CULL_FACE);
    gl.enable(gl.DEPTH_TEST);

    var timer_matrix: Timer = .{};
    var timer_ubo: Timer = .{};
    var timer_draw: Timer = .{};
    var model: Mat4 = Mat4.identity();

    {
        timer_matrix.start();
        defer timer_matrix.stop();
        self.projection_matrix = generate_projection_matrix(self.render_data.width, self.render_data.height, self.render_data.field_of_view);
        const angle: f32 = @floatFromInt(self.render_data.ticks);
        if (self.render_data.use_changed_shader) {
            model = model.rotate(angle, Vec3.new(0, 0, 1));
            self.shader_changed.use();
        } else {
            model = model.rotate(-angle, Vec3.new(0, 0, 1));
            self.shader.use();
        }
    }

    {
        timer_ubo.start();
        defer timer_ubo.stop();
        self.uniform_buffer.upload_data(self.camera.get_view_matrix(&self.render_data).mul(model), self.projection_matrix);
    }

    {
        timer_draw.start();
        defer timer_draw.stop();
        self.texture.bind();
        defer self.texture.unbind();
        self.vertex_buffer.bind();
        defer self.vertex_buffer.unbind();

        self.vertex_buffer.draw(gl.TRIANGLES, 0, self.render_data.triangle_count * 3);

        self.framebuffer.draw_to_screen();
    }

    self.render_data.matrix_generate_time = timer_matrix.get_time();
    self.render_data.upload_to_ubo_time = timer_ubo.get_time();
    self.render_data.render_time = timer_draw.get_time();
}

pub fn shader_swap(self: *Renderer) void {
    self.render_data.use_changed_shader = !self.render_data.use_changed_shader;
}

pub fn handle_event(self: *Renderer, event: InputEvent) void {
    switch (event) {
        .switch_shader => {
            self.shader_swap();
        },
        .camera_control => {
            self.render_data.camera_control = !self.render_data.camera_control;
            Logger.log("Giving camera control");
        },
        else => {

        }
    }
}