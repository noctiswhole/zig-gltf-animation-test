const Model = @This();
const std = @import("std");
const data = @import("data.zig");
const Mesh = data.Mesh;
const Vertex = data.Vertex;

mesh: Mesh,

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
        .mesh = mesh,
    };
}

pub fn deinit(self: *Model, allocator: std.mem.Allocator) void {
    self.mesh.deinit(allocator);
}