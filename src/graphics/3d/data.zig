const zmath = @import("zmath");
const std = @import("std");


pub const Vertex = extern struct {
    position: Position,
    normal: Normal,
    color: Color,
    uv: UV,

    const Color = [3]f32;
    const Position = [3]f32;
    const Normal = [3]f32;
    const UV = [2]f32;
};

pub const Mesh = std.ArrayListUnmanaged(Vertex);

pub const Mat4 = [16]f32; // Simplified matrix type

pub const RenderData = extern struct {
    width: usize,
    height: usize,
    triangle_count: usize,
    field_of_view: i32,
    use_changed_shader: bool = false,
    frame_time: usize = 0,
    matrix_generate_time: f32 = 0,
    upload_to_ubo_time: f32 = 0,
    ui_generate_time: f32 = 0,
    ui_draw_time: f32 = 0,
    ticks: usize = 0,
    fps: f32 = 0,
};
