const sdl3 = @import("sdl3");
const std = @import("std");
const gl = @import("gl");
const Window = @import("Window.zig");
const fps = 60;
const screen_width = 640;
const screen_height = 480;

// Disable main hack.
pub const _start = void;
pub const WinMainCRTStartup = void;
/// Allocator we will use.
const allocator = std.heap.smp_allocator;
comptime {
    _ = sdl3.main_callbacks;
}

const AppState = struct {
    frame_capper: sdl3.extras.FramerateCapper(f32),
    window: Window,
};

pub fn init(
    app_state: *?*AppState,
    args: [][*:0]u8,
) !sdl3.AppResult {
    _ = args;
    var window = try Window.init(allocator, "Hello SDL", 640, 480);
    errdefer window.deinit() catch {
        @panic("could not destroy window");
    };
    const frame_capper = sdl3.extras.FramerateCapper(f32){ .mode = .{ .unlimited = {} } };

    const state = try allocator.create(AppState);
    errdefer allocator.destroy(state);
    state.* = .{
        .window = window,
        .frame_capper = frame_capper,
    };
    app_state.* = state;
    return .run;
}

pub fn event(
    app_state: *AppState,
    curr_event: sdl3.events.Event,
) !sdl3.AppResult {
    switch (curr_event) {
        .terminating => return .success,
        .quit => return .success,
        .window_resized =>  {

            try app_state.window.event_window_resized();
            return .run;
        },
        .key_down => {
            if (curr_event.key_down.key) |keycode| {
                app_state.window.event_keyboard(keycode);
            }
        },
        else => {},
    }
    return .run;
}

pub fn quit(
    app_state: ?*AppState,
    result: sdl3.AppResult,
) void {
    _ = result;
    if (app_state) |state| {
        state.window.deinit() catch {
            @panic("Could not destroy window");
        };
        allocator.destroy(state);
    }
}

pub fn iterate(app_state: *AppState) !sdl3.AppResult {
    const dt = app_state.frame_capper.delay();
    _ = dt;


    app_state.window.main_loop() catch {
        @panic("Main loop error");
    };
    return .run;
}