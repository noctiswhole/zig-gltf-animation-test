const Texture = @This();
const gl = @import("gl");
const sdl3 = @import("sdl3");

texture: gl.GLuint,

pub fn deinit(self: Texture) void {
    gl.deleteTextures(1, &self.texture);
}

pub fn texture_from_file(filename: [:0]const u8) !Texture {
    const surface = try sdl3.image.loadFile(filename);
    defer surface.deinit();

    var texture: gl.GLuint = undefined;
    gl.genTextures(1, &texture);
    gl.bindTexture(gl.TEXTURE_2D, texture);

    const pixel_format: gl.GLuint = gl.RGBA;
    const texture_type: gl.GLenum = gl.UNSIGNED_BYTE;

    if (surface.getPixels()) | pixels | {
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        gl.texImage2D(
            gl.TEXTURE_2D,
            0,
            gl.SRGB8_ALPHA8,
            @intCast(surface.getWidth()),
            @intCast(surface.getHeight()),
            0,
            pixel_format,
            texture_type,
            pixels.ptr,
        );
        gl.generateMipmap(gl.TEXTURE_2D);
    } else {
        return error.MissingSurfacePixels;
    }

    gl.bindTexture(gl.TEXTURE_2D, 0);
    return .{
        .texture = texture,
    };
}

pub fn bind(self: Texture) void {
    gl.bindTexture(gl.TEXTURE_2D, self.texture);
}

pub fn unbind(_: Texture) void {
    gl.bindTexture(gl.TEXTURE_2D, 0);
}