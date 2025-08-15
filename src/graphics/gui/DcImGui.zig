const DcImGui = @This();
const sdl3 = @import("sdl3");
pub const c = @cImport({
    @cInclude("dcimgui.h");
    @cInclude("backends/dcimgui_impl_sdl3.h");
    @cInclude("backends/dcimgui_impl_opengl3.h");
});

context: *c.ImGuiContext,

pub fn init(window: sdl3.video.Window, context: sdl3.video.gl.Context) !DcImGui {
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

pub fn event(_: *DcImGui) void {
    _ = c.cImGui_ImplSDL3_ProcessEvent(&event);
}

pub fn draw(_: *DcImGui) void {
    c.cImGui_ImplOpenGL3_NewFrame();
    c.cImGui_ImplSDL3_NewFrame();
    c.ImGui_NewFrame();
    c.ImGui_ShowDemoWindow(null);
    c.ImGui_Render();
    c.cImGui_ImplOpenGL3_RenderDrawData(c.ImGui_GetDrawData());
}

pub fn deinit(self: *DcImGui) void {
    c.cImGui_ImplOpenGL3_Shutdown();
    c.cImGui_ImplSDL3_Shutdown();
    c.ImGui_DestroyContext(self.context);
}