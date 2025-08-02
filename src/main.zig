const sdl3 = @import("sdl3");
const std = @import("std");
const gl = @import("gl");

const fps = 60;
const screen_width = 640;
const screen_height = 480;

pub fn getProcAddress(p: sdl3.video.gl.Context, proc: [:0]const u8) *const anyopaque {
    _ = p;
    return sdl3.video.gl.getProcAddress(proc);
}

pub fn main() !void {
    defer sdl3.shutdown();

    // Initialize SDL with subsystems you need here.
    const init_flags = sdl3.InitFlags{ .video = true, .events = true };
    try sdl3.init(init_flags);
    defer sdl3.quit(init_flags);
    try sdl3.video.gl.setAttribute(.context_major_version, 4);
    try sdl3.video.gl.setAttribute(.context_minor_version, 6);
    try sdl3.video.gl.setAttribute(.context_profile_mask, @intFromEnum(sdl3.video.gl.Profile.core));


    // Initial window setup.
    const window = try sdl3.video.Window.init("Hello SDL3", screen_width, screen_height, .{
        .open_gl = true,
    });
    defer window.deinit();
    
    const context = try sdl3.video.gl.Context.init(window);
    defer context.deinit() catch {
        @panic("Could not destroy context");
    };
    try gl.load(context, getProcAddress);

    // Useful for limiting the FPS and getting the delta time.
    var fps_capper = sdl3.extras.FramerateCapper(f32){ .mode = .{ .limited = fps } };

    while (true) {

        // Delay to limit the FPS, returned delta time not needed.
        const dt = fps_capper.delay();
        _ = dt;

        // Update logic.
        // const surface = try window.getSurface();
        // // try surface.fillRect(null, surface.mapRgb(128, 30, 255));
        // try surface.clear(.{
        //     .a = 0,
        //     .r = 1,
        //     .g = 1,
        //     .b = 1,
        // });
        // zgl.clearColor(1, 1, 1, 1);
        // zgl.clear(.{
        //     .color = true,
        // });
        gl.clearColor(1, 1, 0, 1);
        gl.clear(gl.COLOR_BUFFER_BIT);
        try sdl3.video.gl.swapWindow(window);
        //
        // Event logic.
        if (sdl3.events.poll()) |event|
            switch (event) {
                .quit => break,
                .terminating => break,
                else => {},
            };
    }
}