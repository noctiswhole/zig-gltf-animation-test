const Window = @This();
const Renderer = @import("graphics/opengl/Renderer.zig");
const sdl3 = @import("sdl3");
const gl = @import("gl");
const std = @import("std");

const SDL_INIT_FLAGS = sdl3.InitFlags{
    .video = true,
    .events = true,
};

pub fn getProcAddress(p: sdl3.video.gl.Context, proc: [:0]const u8) *const anyopaque {
    _ = p;
    return sdl3.video.gl.getProcAddress(proc);
}

window: sdl3.video.Window,
context: sdl3.video.gl.Context,
renderer: Renderer,

pub fn init(allocator: std.mem.Allocator, window_title: [:0]const u8, screen_width: usize, screen_height: usize) !Window {
    // Initialize SDL with subsystems you need here.

    try sdl3.init(SDL_INIT_FLAGS);

    try sdl3.video.gl.setAttribute(.context_major_version, 4);
    try sdl3.video.gl.setAttribute(.context_minor_version, 6);
    try sdl3.video.gl.setAttribute(.context_profile_mask, @intFromEnum(sdl3.video.gl.Profile.core));

    // Initial window setup.
    const window = try sdl3.video.Window.init(window_title, screen_width, screen_height, .{
        .open_gl = true,
        .resizable = true,
    });

    const context = try sdl3.video.gl.Context.init(window);

    try gl.load(context, getProcAddress);
    const renderer = try Renderer.init(allocator, 640, 480);
    return .{
        .window = window,
        .context = context,
        .renderer = renderer,
    };
}

pub fn deinit(self: *Window) !void {
    self.renderer.deinit();
    self.window.deinit();
    try self.context.deinit();
}

pub fn swap(self: Window) !void {
    try sdl3.video.gl.swapWindow(self.window);
}

pub fn main_loop(self: Window) !void {
    try sdl3.video.gl.setSwapInterval(.vsync);
    self.renderer.draw();
    try self.swap();
}