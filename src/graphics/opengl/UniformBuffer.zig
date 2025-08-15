const UniformBuffer = @This();
const Logger = @import("../../io/Logger.zig").makeLogger("UniformBuffer");
const std = @import("std");
const gl = @import("gl");
const zalgebra = @import("zalgebra");
const Mat4 = zalgebra.Mat4;

ubo: gl.GLuint,

pub fn init() UniformBuffer {
    var ubo: gl.GLuint = undefined;
    gl.genBuffers(1, &ubo);
    gl.bindBuffer(gl.UNIFORM_BUFFER, ubo);
    gl.bufferData(gl.UNIFORM_BUFFER, 2 * @sizeOf(Mat4), null, gl.STATIC_DRAW);
    gl.bindBuffer(gl.UNIFORM_BUFFER, 0);
    gl.bindBufferRange(gl.UNIFORM_BUFFER, 0, ubo, 0, 2 * @sizeOf(Mat4));

    Logger.log("UBO initialized");

    return .{
        .ubo = ubo,
    };
}

pub fn upload_data(self: UniformBuffer, view_matrix: Mat4, projection_matrix: Mat4) void {
    gl.namedBufferSubData(self.ubo, 0, @sizeOf(Mat4), &view_matrix);
    gl.namedBufferSubData(self.ubo, @sizeOf(Mat4), @sizeOf(Mat4), &projection_matrix);
}

pub fn deinit(self: *UniformBuffer) void {
    gl.deleteBuffers(1, &self.ubo);
}