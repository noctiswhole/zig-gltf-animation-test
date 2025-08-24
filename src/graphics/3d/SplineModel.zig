const SplineModel = @This();
const std = @import("std");
const data = @import("data.zig");
const Mesh = data.Mesh;
const Vertex = data.Vertex;
const zalgebra = @import("zalgebra");
const Vec3 = zalgebra.Vec3;
const spline = @import("../../tools/spline.zig");

mesh: Mesh,
num_spline_points: usize,

pub fn init(allocator: std.mem.Allocator, num_spline_points: usize) !SplineModel {
    // _ = num_spline_points;
    var mesh: Mesh = .empty;

    const total_vertices: usize = num_spline_points * 2;
    try mesh.resize(allocator, total_vertices);

    // Initialize tangent vertices
    // mesh.items[0] = .{
    //     .position = .{0, 0, 0},
    //     // .position = .{start_vertex.x(), start_vertex.y(), start_vertex.z()},
    //     .normal = .{0, 0, 0},
    //     .color = .{0, 0, 0},
    //     .uv = .{0, 0},
    // };
    //
    // // const t1: Vec3 = start_vertex.add(start_tangent);
    // mesh.items[1] = .{
    //     // .position = .{t1.x(), t1.y(), t1.z()},
    //     .position = .{0, 0, 0},
    //     .normal = .{0, 0, 0},
    //     .color = .{0, 0, 0},
    //     .uv = .{1, 0},
    // };
    //
    // mesh.items[2] = .{
    //     // .position = .{end_vertex.x(), end_vertex.y(), end_vertex.z()},
    //     .normal = .{0, 0, 0},
    //     .position = .{0, 0, 0},
    //     .color = .{0.8, 0.8, 0.8},
    //     .uv = .{0, 1},
    // };
    //
    // // const t2: Vec3 = end_vertex.add(end_tangent);
    // mesh.items[3] = .{
    //     .position = .{0, 0, 0},
    //     // .position = .{t2.x(), t2.y(), t2.z()},
    //     .normal = .{0, 0, 0},
    //     .color = .{0.8, 0.8, 0.8},
    //     .uv = .{1, 1},
    // };



    return .{
        .mesh = mesh,
        .num_spline_points = num_spline_points,
    };
}

pub fn update_spline(self: *SplineModel, start_vertex: Vec3, start_tangent: Vec3, end_vertex: Vec3, end_tangent: Vec3) void {
    // // Generate spline points
    const offset: f32 = 1.0 / @as(f32, @floatFromInt(self.num_spline_points));
    var value: f32 = 0;

    for (self.mesh.items, 0..) |*vertex, i| {
        const pos: Vec3 = spline.hermite(start_vertex, start_tangent, end_vertex, end_tangent, value);
        if (i % 2 == 0) {
            vertex.position = .{pos.x(), pos.y(), pos.z()};
            vertex.color = .{value, value, value};
            value += offset;
        } else {
            vertex.position = .{pos.x(), pos.y(), pos.z()};
            vertex.color = .{value, value, value};
        }
    }
    //
    // // Set final vertex
    self.mesh.items[self.mesh.items.len - 1].position = .{end_vertex.x(), end_vertex.y(), end_vertex.z()};
    self.mesh.items[self.mesh.items.len - 1].color = .{value, value, value};
}

pub fn deinit(self: *SplineModel, allocator: std.mem.Allocator) void {
    self.mesh.deinit(allocator);
}