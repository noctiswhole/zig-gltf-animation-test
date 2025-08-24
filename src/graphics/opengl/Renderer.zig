const Renderer = @This();
const Framebuffer = @import("Framebuffer.zig");
const Texture = @import("Texture.zig");
const Shader = @import("Shader.zig");
const VertexBuffer = @import("VertexBuffer.zig");
const UniformBuffer = @import("UniformBuffer.zig");
const Timer = @import("../../tools/Timer.zig");
const data = @import("../3d/data.zig");
const Mesh = data.Mesh;
const Model = @import("../3d/Model.zig");
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
const Input = @import("../../io/Input.zig");
const math = std.math;
const spline = @import("../../tools/spline.zig");
const SplineModel = @import("../3d/SplineModel.zig");
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
temp_mesh: Mesh,
camera: Camera = .{},
model: Model,
spline_model: SplineModel,

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

    const mesh = try Mesh.initCapacity(allocator, 100);
    const model: Model = try Model.init(allocator);

    const spline_model: SplineModel = try SplineModel.init(allocator, 25);

    const render_data: RenderData = .{
        .width = width,
        .height = height,
        .triangle_count = 0,
        .field_of_view = DEFAULT_FOV,
    };
    return .{
        .framebuffer = framebuffer,
        .model = model,
        .temp_mesh = mesh,
        .texture = texture,
        .shader = shader,
        .vertex_buffer = vertex_buffer,
        .uniform_buffer = uniform_buffer,
        .shader_changed = shader_changed,
        .projection_matrix = generate_projection_matrix(width, height, DEFAULT_FOV),
        .render_data = render_data,
        .spline_model = spline_model,
    };
}

pub fn deinit(self: *Renderer, allocator: std.mem.Allocator) void {
    self.texture.deinit();
    self.uniform_buffer.deinit();
    self.shader.deinit();
    self.framebuffer.deinit();
    self.vertex_buffer.deinit();
    self.model.deinit(allocator);
    self.temp_mesh.deinit(allocator);
}

fn generate_projection_matrix(width: usize, height: usize, fov: f32) Mat4 {
    // return zmath.perspectiveFovRhGl(0.25 * math.pi, @as(f32, @floatFromInt(width))/@as(f32, @floatFromInt(height)), 0.1, 20.0);
    return zalgebra.perspective(fov, @as(f32, @floatFromInt(width))/@as(f32, @floatFromInt(height)), 0.1, 100.0);
}

pub fn upload_data(self: *Renderer, mesh: Mesh) void {
    // self.temp_mesh.clearRetainingCapacity();

    self.render_data.triangle_count = mesh.items.len / 3;
    // self.vertex_buffer.upload_data(mesh);
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

pub fn update(self: *Renderer, frame_capper: sdl3.extras.FramerateCapper(f32), input: Input) void {
    self.render_data.ticks = frame_capper.frame_num;
    self.render_data.frame_time = frame_capper.dt;
    self.render_data.fps = frame_capper.getObservedFps();

    self.camera.handle_input(input, @as(f32, @floatFromInt(frame_capper.dt))/1000000000);

    self.camera.update_vectors();

    self.render_data.view_azimuth = self.camera.yaw;
    self.render_data.view_elevation = self.camera.pitch;
}

pub fn draw(self: *Renderer) void {
    self.framebuffer.bind();
    defer self.framebuffer.unbind();
    gl.clearColor(0.1, 0.1, 0.1, 1);
    gl.clearDepth(1.0);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    gl.disable(gl.CULL_FACE);
    gl.enable(gl.DEPTH_TEST);

    var timer_matrix: Timer = .{};
    var timer_ubo: Timer = .{};
    var timer_draw: Timer = .{};
    var model: Mat4 = Mat4.identity();
    model = model;

    {
        timer_matrix.start();
        defer timer_matrix.stop();
        self.projection_matrix = generate_projection_matrix(self.render_data.width, self.render_data.height, self.render_data.field_of_view);
        // const angle: f32 = @floatFromInt(self.render_data.ticks);
        if (self.render_data.use_changed_shader) {
            // model = model.rotate(angle, Vec3.new(0, 0, 1));
            self.shader_changed.use();
        } else {
            // model = model.rotate(-angle, Vec3.new(0, 0, 1));
            self.shader.use();
        }
    }

    {
        timer_ubo.start();
        defer timer_ubo.stop();
        self.uniform_buffer.upload_data(self.camera.get_view_matrix().mul(model), self.projection_matrix);
    }

    {
        timer_draw.start();
        defer timer_draw.stop();
        self.texture.bind();
        defer self.texture.unbind();

        self.temp_mesh.clearRetainingCapacity();
        const start_vertex: Vec3 = Vec3.new(-4.0, 1.0, -2.0);
        const start_tangent: Vec3 = Vec3.new(-10.0, -8.0, 8.0);
        const end_vertex: Vec3 = Vec3.new(4.0, 2.0, -2.0);
        const end_tangent: Vec3 = Vec3.new(-6.0, 5.0, -6.0);

        self.spline_model.update_spline(start_vertex, start_tangent, end_vertex, end_tangent);

        for (self.spline_model.mesh.items) |vertex| {
            self.temp_mesh.appendAssumeCapacity(vertex);
        }

        // TODO: Maintain separate VBO for splines
        const value = self.render_data.spline_position;
        const interpolated_position = spline.hermite(start_vertex,
            start_tangent, end_vertex, end_tangent, value);

        for (self.model.mesh.items) |vertex| {
            var vert = vertex;
            vert.position = .{
                vert.position[0] + interpolated_position.x(),
                vert.position[1] + interpolated_position.y(),
                vert.position[2] + interpolated_position.z(),
            };
            self.temp_mesh.appendAssumeCapacity(vert);
        }

        self.render_data.triangle_count = self.temp_mesh.items.len / 3;
        self.vertex_buffer.upload_data(self.temp_mesh);

        self.vertex_buffer.bind();
        defer self.vertex_buffer.unbind();

        self.vertex_buffer.draw(gl.LINES, 0, self.spline_model.num_spline_points * 2);

        self.vertex_buffer.draw(gl.TRIANGLES, self.spline_model.num_spline_points * 2, self.render_data.triangle_count * 3);

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
        else => {

        }
    }
}

pub fn handle_event_mouse_motion(self: *Renderer, x_rel: f32, y_rel: f32) void {
    // SDL y direction is flipped
    self.camera.handle_event_mouse_motion(x_rel, -y_rel);

}