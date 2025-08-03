const Window = @This();
const sdl3 = @import("sdl3");
const gl = @import("gl");

const WindowOptions = struct {
    width: u32,
};

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

pub fn init(window_title: [:0]const u8, screen_width: usize, screen_height: usize) !Window {
    // Initialize SDL with subsystems you need here.

    try sdl3.init(SDL_INIT_FLAGS);

    try sdl3.video.gl.setAttribute(.context_major_version, 4);
    try sdl3.video.gl.setAttribute(.context_minor_version, 6);
    try sdl3.video.gl.setAttribute(.context_profile_mask, @intFromEnum(sdl3.video.gl.Profile.core));



    // Initial window setup.
    const window = try sdl3.video.Window.init(window_title, screen_width, screen_height, .{
        .open_gl = true,
    });

    const context = try sdl3.video.gl.Context.init(window);

    try gl.load(context, getProcAddress);
    return .{
        .window = window,
        .context = context,
    };
}

pub fn deinit(self: *Window) !void {
    self.window.deinit();
    sdl3.quit(SDL_INIT_FLAGS);
    sdl3.shutdown();
    try self.context.deinit();
}

pub fn swap(self: *Window) !void {
    try sdl3.video.gl.swapWindow(self.window);
}