const Gui = @This();
const RenderData = @import("../../3d/data.zig").RenderData;
const sdl3 = @import("sdl3");
pub const c = @cImport({
    @cInclude("dcimgui.h");
    @cInclude("backends/dcimgui_impl_sdl3.h");
    @cInclude("backends/dcimgui_impl_opengl3.h");
});

context: *c.ImGuiContext,

pub fn init(window: sdl3.video.Window, context: sdl3.video.gl.Context) !Gui {
    if (c.ImGui_CreateContext(null))  | imgui_context| {
        const imio = c.ImGui_GetIO();
        imio.*.ConfigFlags = c.ImGuiConfigFlags_NavEnableKeyboard;
        c.ImGui_StyleColorsDark(null);

        if (!c.cImGui_ImplSDL3_InitForOpenGL(@ptrCast(window.value), @ptrCast(context.value))) {
            return error.DcImGuiInitOpenglFailed;
        }
        if (!c.cImGui_ImplOpenGL3_InitEx("#version 460 core")) {
            return error.DcImGuiSetOpenglVersionFailed;
        }
        return .{
            .context = imgui_context,
        };
    } else {
        return error.DcImGuiContextCreationFailed;
    }
}

pub fn event_handle(_: *Gui, event: sdl3.events.Event) bool {
    return c.cImGui_ImplSDL3_ProcessEvent(@ptrCast(&sdl3.events.Event.toSdl(event)));
}

pub fn create_frame(_: *Gui, render_data: RenderData) void {
    c.cImGui_ImplOpenGL3_NewFrame();
    c.cImGui_ImplSDL3_NewFrame();
    c.ImGui_NewFrame();

    var window_flags: c.ImGuiWindowFlags = 0;
    window_flags |= c.ImGuiWindowFlags_NoCollapse;

    c.ImGui_SetNextWindowBgAlpha(0.8);
    // c.ImGui_ShowDemoWindow(null);
    _ = c.ImGui_Begin("Control", null, window_flags);
    _ = c.ImGui_Text("Triangles: %d", render_data.triangle_count);
    _ = c.ImGui_Text("Window Dimensions: %dx%d", render_data.width, render_data.height);
    _ = c.ImGui_End();
}

pub fn draw(_: *Gui) void {
    c.ImGui_Render();
    c.cImGui_ImplOpenGL3_RenderDrawData(c.ImGui_GetDrawData());
}

pub fn deinit(self: *Gui) void {
    c.cImGui_ImplOpenGL3_Shutdown();
    c.cImGui_ImplSDL3_Shutdown();
    c.ImGui_DestroyContext(self.context);
}