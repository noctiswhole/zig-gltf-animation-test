const sdl3 = @import("sdl3");
const std = @import("std");
const gl = @import("gl");
const Window = @import("Window.zig");
const fps = 60;
const screen_width = 640;
const screen_height = 480;



pub fn main() !void {
    var window: Window = try Window.init("Hello SDL!", 640, 480);
    defer window.deinit() catch {
        @panic("Could not destroy window");
    };
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
        try window.swap();
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