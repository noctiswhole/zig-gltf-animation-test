const Framebuffer = @This();
const gl = @import("gl");
const Logger = @import("../../io/Logger.zig").makeLogger("FrameBuffer");

buffer_width: usize = 640,
buffer_height: usize = 480,
frame_buffer: gl.GLuint,
color_texture: gl.GLuint,
depth_buffer: gl.GLuint,

pub fn init(width: usize, height: usize) !Framebuffer {
    var frame_buffer: gl.GLuint = 0;
    gl.genFramebuffers(1, &frame_buffer);
    gl.bindFramebuffer(gl.FRAMEBUFFER, frame_buffer);

    const color_texture = create_color_texture(width, height);
    gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, color_texture, 0);

    const depth_buffer: gl.GLuint = create_depth_stencil_buffer(width, height);
    gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.DEPTH_STENCIL_ATTACHMENT, gl.RENDERBUFFER, depth_buffer);

    gl.bindFramebuffer(gl.FRAMEBUFFER, 0);

    if (!check_complete(frame_buffer)) {
        return error.FramebufferCreateFailed;
    }

    Logger.log("FrameBuffer initialized");

    return .{
        .buffer_width = width,
        .buffer_height = height,
        .frame_buffer = frame_buffer,
        .color_texture = color_texture,
        .depth_buffer = depth_buffer,
    };
}

inline fn create_color_texture(width: usize, height: usize) gl.GLuint {
    var color_texture: gl.GLuint = 0;
    gl.genTextures(1, &color_texture);
    gl.bindTexture(gl.TEXTURE_2D, color_texture);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA8, @intCast(width), @intCast(height), 0, gl.RGBA, gl.UNSIGNED_BYTE, null);

    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    gl.bindTexture(gl.TEXTURE_2D, 0);
    return color_texture;
}

inline fn create_depth_stencil_buffer(width: usize, height: usize) gl.GLuint {
    var depth_buffer: gl.GLuint = 0;
    gl.genRenderbuffers(1, &depth_buffer);
    gl.bindRenderbuffer(gl.RENDERBUFFER, depth_buffer);
    gl.renderbufferStorage(gl.RENDERBUFFER, gl.DEPTH24_STENCIL8, @intCast(width), @intCast(height));
    gl.bindRenderbuffer(gl.RENDERBUFFER, 0);
    return depth_buffer;
}

pub fn bind(self: Framebuffer) void {
    gl.bindFramebuffer(gl.DRAW_FRAMEBUFFER, self.frame_buffer);
}

pub fn unbind(_: Framebuffer) void {
    gl.bindFramebuffer(gl.DRAW_FRAMEBUFFER, 0);
}

pub fn draw_to_screen(self: Framebuffer) void {
    gl.blitNamedFramebuffer(
        self.frame_buffer,
        0, 0, 0,
        @intCast(self.buffer_width),
        @intCast(self.buffer_height),
        0, 0,
        @intCast(self.buffer_width),
        @intCast(self.buffer_height),
        gl.COLOR_BUFFER_BIT,
        gl.NEAREST
    );
}

fn check_complete(frame_buffer: gl.GLuint) bool {
    const result = gl.checkNamedFramebufferStatus(frame_buffer, gl.FRAMEBUFFER);
    if (result != gl.FRAMEBUFFER_COMPLETE) {
        return false;
    }
    return true;
}

pub fn resize(self: *Framebuffer, width: usize, height: usize) !void {
    self.buffer_width = width;
    self.buffer_height = height;

    self.deinit();

    const new_framebuffer = try init(width, height);
    self.color_texture = new_framebuffer.color_texture;
    self.depth_buffer = new_framebuffer.depth_buffer;
    self.frame_buffer = new_framebuffer.frame_buffer;
}

pub fn deinit(self: *Framebuffer) void {
    self.unbind();
    gl.deleteTextures(1, &self.color_texture);
    gl.deleteRenderbuffers(1, &self.depth_buffer);
    gl.deleteFramebuffers(1, &self.frame_buffer);
}