const Camera = @This();
const data = @import("data.zig");
const zalgebra = @import("zalgebra");
const Vec3 = zalgebra.Vec3;
const Mat4 = zalgebra.Mat4;
const RenderData = data.RenderData;
const std = @import("std");
const math = std.math;

const WORLD_UP = Vec3.new(0, 1, 0);

// defaults
const POSITION = Vec3.new(3, 3, 3);
const FRONT = Vec3.new(0, 0, -1);
const RIGHT = FRONT.cross(WORLD_UP).norm();
const UP = RIGHT.cross(FRONT).norm();

position: Vec3 = POSITION,
front: Vec3 = FRONT,
right: Vec3 = RIGHT,
up: Vec3 = UP,

yaw: f32 = 0,
pitch: f32 = 0,

pub fn update_vectors(self: *Camera) void {
    const azimuth_radians: f32 = zalgebra.toRadians(self.yaw);
    const elevation_radians: f32 = zalgebra.toRadians(self.pitch);
    const azimuth_sin: f32 = math.sin(azimuth_radians);
    const azimuth_cos: f32 = math.cos(azimuth_radians);
    const elevation_sin: f32 = math.sin(elevation_radians);
    const elevation_cos: f32 = math.cos(elevation_radians);
    self.front = Vec3.new(azimuth_sin * elevation_cos, elevation_sin, -azimuth_cos * elevation_cos).norm();
    self.right = self.front.cross(WORLD_UP).norm();
    self.up    = self.right.cross(self.front).norm();
}

pub fn get_view_matrix(self: *Camera) zalgebra.Mat4 {
    return zalgebra.lookAt(self.position, self.position.add(self.front), WORLD_UP);
}

pub fn handle_event_mouse_motion(self: *Camera, x_rel: f32, y_rel: f32) void {
    self.yaw += x_rel;
    self.pitch += y_rel;

    // constrain rotation
    if (self.yaw < 0) {
        self.yaw += 360;
    }
    if (self.yaw > 360) {
        self.yaw -= 360;
    }

    if (self.pitch > 89) {
        self.pitch = 89;
    }
    if (self.pitch < -89) {
        self.pitch = -89;
    }

}