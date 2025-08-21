const Input = @This();
const std = @import("std");
const InputEnum = @import("InputMap.zig").InputEvent;

const InputEvent = struct {
    up: bool = false,
    down: bool = false,
    value: bool = false,
};

const InputMap = std.AutoHashMapUnmanaged(InputEnum, InputEvent);

input: InputMap,


// TODO: handle down/up events
// TODO: create mapping at runtime
// const keymap = StaticStringMap.initComptime(.{
//     .{ "space", .switch_shader },
//     .{ "right", .camera_control },
//     .{ "w", .camera_forward},
//     .{ "s", .camera_backward},
// });

pub fn init(allocator: std.mem.Allocator) !Input {
    var input_map: InputMap = .{};

    // TODO: use reflection to generate map
    try input_map.put(allocator, .camera_forward, .{});
    try input_map.put(allocator, .camera_backward, .{});
    try input_map.put(allocator, .camera_left, .{});
    try input_map.put(allocator, .camera_right, .{});
    try input_map.put(allocator, .camera_down, .{});
    try input_map.put(allocator, .camera_up, .{});

    return .{
        .input = input_map,
    };
}

pub fn is_pressed(self: Input, input_enum: InputEnum) bool {
    if (self.input.get(input_enum)) |event| {
        return event.value;
    } else {
        return false;
    }
}

pub fn clear_events(self: *Input) void {
    for (self.input.valueIterator().next()) | entry | {
        var edit_entry = entry;
        edit_entry.value_ptr.down = false;
        edit_entry.value_ptr.up = false;
    }
}

pub fn handle_event_down(self: *Input, input_enum: InputEnum) void {
    if (self.input.getPtr(input_enum)) | event | {
        event.down = true;
        event.value = true;
    }
}

pub fn handle_event_up(self: *Input, input_enum: InputEnum) void {
    if (self.input.getPtr(input_enum)) | event | {
        event.up = true;
        event.value = false;
    }
}

pub fn deinit(self: *Input, allocator: std.mem.Allocator) void {
    self.input.deinit(allocator);
}