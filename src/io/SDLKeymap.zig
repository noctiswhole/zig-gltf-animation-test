const std = @import("std");
const sdl3 = @import("sdl3");
const InputMap = @import("InputMap.zig");
const InputEvent = InputMap.InputEvent;
const StaticStringMap = std.StaticStringMap(InputEvent);

// TODO: create mapping at runtime
const keymap = StaticStringMap.initComptime(.{
    .{ "space", .switch_shader },
});

pub fn get_event_from_sdl_keyboard(keyboard: sdl3.keycode.Keycode) ?InputEvent {
    if (keymap.get(@tagName(keyboard))) | input | {
        return input;
    } else {
        return null;
    }
}