const Camera = @This();
const data = @import("data.zig");
const zalgebra = @import("zalgebra");
const Vec3 = zalgebra.Vec3;
const Mat4 = zalgebra.Mat4;
const RenderData = data.RenderData;
const std = @import("std");
const math = std.math;

world_position: zalgebra.Vec3 = Vec3.new(3, 3,3),
view_direction: zalgebra.Vec3 = Vec3.new(0, 0, 0),
world_up_vector: zalgebra.Vec3 = Vec3.new(0, 1, 0),

pub fn get_view_matrix(self: *Camera, render_data: *RenderData) zalgebra.Mat4 {
    const azimuth_radians: f32 = zalgebra.toRadians(render_data.view_azimuth);
    const elevation_radians: f32 = zalgebra.toRadians(render_data.view_elevation);
    const azimuth_sin: f32 = math.sin(azimuth_radians);
    const azimuth_cos: f32 = math.cos(azimuth_radians);
    const elevation_sin: f32 = math.sin(elevation_radians);
    const elevation_cos: f32 = math.cos(elevation_radians);
    self.view_direction = Vec3.new(azimuth_sin * elevation_cos, elevation_sin, -azimuth_cos * elevation_cos).norm();
    return zalgebra.lookAt(self.world_position, self.world_position.add(self.view_direction), self.world_up_vector);
}

