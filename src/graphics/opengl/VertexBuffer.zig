const VertexBuffer = @This();
const gl = @import("gl");
const Vertex = @import("../3d/data.zig").Vertex;
const Logger = @import("../../io/Logger.zig").makeLogger("VertexBuffer");
const Mesh = @import("../3d/data.zig").Mesh;
const std = @import("std");
vao: gl.GLuint,
vbo: gl.GLuint,

pub fn init() VertexBuffer {
    var vao: gl.GLuint = undefined;
    gl.genVertexArrays(1, &vao);
    var vbo: gl.GLuint = undefined;
    gl.genBuffers(1, &vbo);
    gl.bindVertexArray(vao);

    gl.bindBuffer(gl.ARRAY_BUFFER, vbo);
    gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, @sizeOf(Vertex), @ptrFromInt(@offsetOf(Vertex, "position")));
    gl.vertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, @sizeOf(Vertex), @ptrFromInt(@offsetOf(Vertex, "color")));
    gl.vertexAttribPointer(2, 2, gl.FLOAT, gl.FALSE, @sizeOf(Vertex), @ptrFromInt(@offsetOf(Vertex, "uv")));

    gl.enableVertexAttribArray(0);
    gl.enableVertexAttribArray(1);
    gl.enableVertexAttribArray(2);

    gl.bindBuffer(gl.ARRAY_BUFFER, 0);
    gl.bindVertexArray(0);

    Logger.log("VAO and VBO initialized");

    return .{
        .vao = vao,
        .vbo = vbo,
    };
}

pub fn upload_data(self: VertexBuffer, mesh: Mesh) void {
    gl.bindVertexArray(self.vao);
    gl.bindBuffer(gl.ARRAY_BUFFER, self.vbo);

    gl.bufferData(gl.ARRAY_BUFFER, @intCast(mesh.items.len * @sizeOf(Vertex)), mesh.items.ptr, gl.DYNAMIC_DRAW);

    gl.bindBuffer(gl.ARRAY_BUFFER, 0);
    gl.bindVertexArray(0);
}

pub fn bind(self: VertexBuffer) void {
    gl.bindVertexArray(self.vao);
    gl.bindBuffer(gl.ARRAY_BUFFER, self.vbo);
}

pub fn unbind(_: VertexBuffer) void {
    gl.bindVertexArray(0);
    gl.bindBuffer(gl.ARRAY_BUFFER, 0);
}

pub fn draw(_: VertexBuffer, mode: gl.GLuint, start: usize, num: usize) void {
    gl.drawArrays(mode, @intCast(start), @intCast(num));
}

pub fn deinit(self: VertexBuffer) void {
    gl.deleteVertexArrays(1, &self.vao);
    gl.deleteBuffers(1, &self.vbo);
}