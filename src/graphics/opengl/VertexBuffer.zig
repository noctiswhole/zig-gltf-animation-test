const VertexBuffer = @This();
const gl = @import("gl");
const Vertex = @import("data.zig").Vertex;
const Logger = @import("../../io/Logger.zig").makeLogger("VertexBuffer");
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
    gl.vertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, @sizeOf(Vertex), @ptrFromInt(@offsetOf(Vertex, "uv")));

    gl.enableVertexAttribArray(0);
    gl.enableVertexAttribArray(1);

    gl.bindBuffer(gl.ARRAY_BUFFER, 0);
    gl.bindVertexArray(0);

    Logger.log("VAO and VBO initialized");

    return .{
        .vao = vao,
        .vbo = vbo,
    };
}

pub fn deinit(self: VertexBuffer) void {
    gl.deleteVertexArrays(1, &self.vao);
    gl.deleteBuffers(1, &self.vbo);
}