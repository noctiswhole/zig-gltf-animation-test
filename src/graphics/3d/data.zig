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