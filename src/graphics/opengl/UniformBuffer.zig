const UniformBuffer = @This();
const Logger = @import("../../io/Logger.zig").makeLogger("UniformBuffer");
const Mat4 = @import("../3d/data.zig").Mat4;
const std = @import("std");
const gl = @import("gl");
const zmath = @import("zmath");

ubo: gl.GLuint,

pub fn init() UniformBuffer {
    var ubo: gl.GLuint = undefined;
    gl.genBuffers(1, &ubo);
    gl.bindBuffer(gl.UNIFORM_BUFFER, ubo);
    gl.bufferData(gl.UNIFORM_BUFFER, 2 * @sizeOf(zmath.Mat), null, gl.STATIC_DRAW);
    gl.bindBuffer(gl.UNIFORM_BUFFER, 0);

    Logger.log("UBO initialized");

    return .{
        .ubo = ubo,
    };
}

pub fn upload_data(self: UniformBuffer, view_matrix: Mat4, projection_matrix: Mat4) void {
    gl.bindBuffer(gl.UNIFORM_BUFFER, self.ubo);
    gl.bufferSubData(gl.UNIFORM_BUFFER, 0, @sizeOf(zmath.Mat), &view_matrix);
    gl.bufferSubData(gl.UNIFORM_BUFFER, @sizeOf(zmath.Mat), @sizeOf(zmath.Mat), &projection_matrix);
    gl.bindBufferRange(gl.UNIFORM_BUFFER, 0, self.ubo, 0, 2 * @sizeOf(zmath.Mat));
    gl.bindBuffer(gl.UNIFORM_BUFFER, 0);
}

pub fn deinit(self: *UniformBuffer) void {
    gl.deleteBuffers(1, &self.ubo);
}