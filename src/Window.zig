const Window = @This();
const Renderer = @import("graphics/opengl/Renderer.zig");
const data = @import("graphics/3d/data.zig");
const RenderData = data.RenderData;
const Timer = @import("tools/Timer.zig");
const Model = @import("graphics/3d/Model.zig");
const SDLKeymap = @import("io/SDLKeymap.zig");
const Gui = @import("graphics/ui/dcimgui/Gui.zig");
const sdl3 = @import("sdl3");
const gl = @import("gl");
const std = @import("std");

pub const WindowData = extern struct {
    ui_generate_time: f32 = 0,
    ui_draw_time: f32 = 0,
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
renderer: Renderer,
window_data: WindowData = .{},
gui: Gui,

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

    const gui = try Gui.init(window, context);

    try gl.load(context, getProcAddress);
    var renderer = try Renderer.init(allocator, 640, 480);

    try sdl3.video.gl.setSwapInterval(.vsync);
    var model: Model = try Model.init(allocator);
    defer model.deinit(allocator);
    renderer.upload_data(model.mesh);

    return .{
        .window = window,
        .context = context,
        .renderer = renderer,
        .gui = gui,
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

pub fn event_handle(self: *Window, event: sdl3.events.Event) !void {
    _ = self.gui.event_handle(event);
    switch (event) {
        .key_down => {
            if (event.key_down.key) |keycode| {
                self.event_keyboard(keycode);
            }
        },
        .mouse_button_down => {
            try self.event_mouse_button(event.mouse_button_down);
        },
        else => {

        }
    }
}

pub fn event_window_resized(self: *Window) !void {
    const size = try self.window.getSize();
    try self.renderer.set_size(size.width, size.height);
}

// TODO: move input to some sort of event system
pub fn event_mouse_button(self: *Window, mouse_button_event: sdl3.events.MouseButton) !void {
    if (SDLKeymap.get_event_from_sdl_mouse_button(mouse_button_event.button)) |event| {
        self.renderer.handle_event(event);
        sdl3.mouse.capture(self.renderer.render_data.camera_control) catch {
            // Wayland mouse capture not supported...
        };
    }

}

// TODO: move input to some sort of event system
pub fn event_keyboard(self: *Window, key_event: sdl3.keycode.Keycode) void {
    if (SDLKeymap.get_event_from_sdl_keyboard(key_event)) |event| {
        self.renderer.handle_event(event);
    }
}

pub fn main_loop(self: *Window, frame_capper: sdl3.extras.FramerateCapper(f32)) !void {
    self.renderer.update(frame_capper);
    self.renderer.draw();

    var gui_frame_timer: Timer = .{};
    var gui_draw_timer: Timer = .{};

    gui_frame_timer.start();
    self.gui.create_frame(&self.renderer.render_data, &self.window_data);
    gui_frame_timer.stop();
    gui_draw_timer.start();
    self.gui.draw();
    gui_draw_timer.stop();

    self.window_data.ui_generate_time = gui_frame_timer.get_time();
    self.window_data.ui_draw_time = gui_draw_timer.get_time();
    try self.swap();
}