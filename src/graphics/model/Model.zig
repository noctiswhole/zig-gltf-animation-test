const Model = @This();
const std = @import("std");
const data = @import("../opengl/data.zig");
const Mesh = data.Mesh;
const Vertex = data.Vertex;

vertex_data: Mesh,

pub fn init(allocator: std.mem.Allocator) !Model {
    var mesh: Mesh = .empty;
    const vertices = [_]Vertex{
        .{
            .position = .{-0.5, -0.5, 0.5},
            .normal = .{0, 0, 0},
            .uv = .{0.0, 0.0},
        },
        .{
            .position = .{0.5, 0.5, 0.5},
            .normal = .{0, 0, 0},
            .uv = .{1.0, 1.0},
        },
        .{
            .position = .{-0.5, 0.5, 0.5},
            .normal = .{0, 0, 0},
            .uv = .{0.0, 1.0},
        },
        .{
            .position = .{-0.5, -0.5, 0.5},
            .normal = .{0, 0, 0},
            .uv = .{0.0, 0.0},
        },
        .{
            .position = .{0.5, -0.5, 0.5},
            .normal = .{0, 0, 0},
            .uv = .{1.0, 0.0},
        },
        .{
            .position = .{0.5, 0.5, 0.5},
            .normal = .{0, 0, 0},
            .uv = .{1.0, 1.0},
        },
    };
    try mesh.appendSlice(allocator, &vertices);

    return .{
        .vertex_data = mesh,
    };
}

pub fn deinit(self: Model, allocator: std.mem.Allocator) void {
    self.vertex_data.deinit(allocator);
}