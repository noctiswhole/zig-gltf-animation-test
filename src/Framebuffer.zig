const Framebuffer = @This();
const gl = @import("gl");
const sdl3 = @import("sdl3");
buffer_width: usize = 640,
buffer_height: usize = 480,
frame_buffer: gl.GLuint,
color_texture: gl.GLuint,
depth_buffer: gl.GLuint,

pub fn init(width: usize, height: usize) !Framebuffer {
    var frame_buffer: gl.GLuint = 0;
    gl.genFramebuffers(1, &frame_buffer);
    gl.bindFramebuffer(gl.FRAMEBUFFER, frame_buffer);

    var color_texture: gl.GLuint = 0;

    gl.genTextures(1, &color_texture);
    gl.bindTexture(gl.TEXTURE_2D, color_texture);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA8, @intCast(width), @intCast(height), 0, gl.RGBA, gl.UNSIGNED_BYTE, null);

    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    gl.bindTexture(gl.TEXTURE_2D, 0);

    gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, color_texture, 0);

    var depth_buffer: gl.GLuint = 0;
    gl.genRenderbuffers(1, &depth_buffer);
    gl.bindRenderbuffer(gl.RENDERBUFFER, depth_buffer);
    gl.renderbufferStorage(gl.RENDERBUFFER, gl.DEPTH24_STENCIL8, @intCast(width), @intCast(height));
    gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.DEPTH_STENCIL_ATTACHMENT, gl.RENDERBUFFER, depth_buffer);
    gl.bindRenderbuffer(gl.RENDERBUFFER, 0);

    gl.bindFramebuffer(gl.FRAMEBUFFER, 0);

    if (!check_complete(frame_buffer)) {
        @panic("Could not create buffer");
        // TODO: error
    }

    return .{
        .buffer_width = width,
        .buffer_height = height,
        .frame_buffer = frame_buffer,
        .color_texture = color_texture,
        .depth_buffer = depth_buffer,
    };
}

pub fn bind(self: Framebuffer) void {
    gl.bindFramebuffer(gl.DRAW_FRAMEBUFFER, self.frame_buffer);
}

pub fn unbind(_: Framebuffer) void {
    gl.bindFramebuffer(gl.DRAW_FRAMEBUFFER, 0);
}

pub fn draw_to_screen(self: Framebuffer) void {
    gl.bindFramebuffer(gl.READ_FRAMEBUFFER, self.frame_buffer);
    gl.bindFramebuffer(gl.DRAW_FRAMEBUFFER, 0);
    gl.blitFramebuffer(0, 0, @intCast(self.buffer_width), @intCast(self.buffer_height), 0, 0, @intCast(self.buffer_width), @intCast(self.buffer_height), gl.COLOR_BUFFER_BIT, gl.NEAREST);
    gl.bindFramebuffer(gl.READ_FRAMEBUFFER, 0);
}

fn check_complete(frame_buffer: gl.GLuint) bool {
    gl.bindFramebuffer(gl.FRAMEBUFFER, frame_buffer);

    const result = gl.checkFramebufferStatus(gl.FRAMEBUFFER);
    if (result != gl.FRAMEBUFFER_COMPLETE) {
        return false;
    }

    gl.bindFramebuffer(gl.FRAMEBUFFER, 0);
    return true;
}

pub fn deinit(self: Framebuffer) void {
    self.unbind();
    gl.deleteTextures(1, &self.color_texture);
    gl.deleteRenderbuffers(1, &self.depth_buffer);
    gl.deleteFramebuffers(1, &self.frame_buffer);
}