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
    // Don't know why this code doesn't work without binding vao
    gl.bindVertexArray(vao);
    gl.vertexArrayVertexBuffer(vao, 0, vbo, 0, @sizeOf(Vertex));
    gl.bindVertexArray(0);

    gl.enableVertexArrayAttrib(vao, 0);
    gl.enableVertexArrayAttrib(vao, 1);
    gl.enableVertexArrayAttrib(vao, 2);

    gl.vertexArrayAttribFormat(vao, 0, 3, gl.FLOAT, gl.FALSE, @offsetOf(Vertex, "position"));
    gl.vertexArrayAttribFormat(vao, 1, 3, gl.FLOAT, gl.FALSE, @offsetOf(Vertex, "color"));
    gl.vertexArrayAttribFormat(vao, 2, 2, gl.FLOAT, gl.FALSE, @offsetOf(Vertex, "uv"));


    gl.vertexArrayAttribBinding(vao, 0, 0);
    gl.vertexArrayAttribBinding(vao, 1, 0);
    gl.vertexArrayAttribBinding(vao, 2, 0);


    Logger.log("VAO and VBO initialized");

    return .{
        .vao = vao,
        .vbo = vbo,
    };
}

pub fn upload_data(self: VertexBuffer, mesh: Mesh) void {
    gl.namedBufferData(self.vbo, @intCast(mesh.items.len * @sizeOf(Vertex)), mesh.items.ptr, gl.DYNAMIC_DRAW);
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