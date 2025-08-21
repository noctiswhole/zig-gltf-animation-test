const Gui = @This();
const RenderData = @import("../../3d/data.zig").RenderData;
const WindowData = @import("../../../Window.zig").WindowData;
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

pub fn create_frame(_: *Gui, render_data: *RenderData, window_data: *WindowData) void {
    c.cImGui_ImplOpenGL3_NewFrame();
    c.cImGui_ImplSDL3_NewFrame();
    c.ImGui_NewFrame();

    var window_flags: c.ImGuiWindowFlags = 0;
    window_flags |= c.ImGuiWindowFlags_NoCollapse;

    c.ImGui_SetNextWindowBgAlpha(0.8);
    // c.ImGui_ShowDemoWindow(null);
    _ = c.ImGui_Begin("Control", null, window_flags);
    _ = c.ImGui_Text("FPS: %.2f", render_data.fps);
    _ = c.ImGui_Separator();
    _ = c.ImGui_Text("Frame Time: %d ms", render_data.frame_time / 1000000);
    _ = c.ImGui_Text("Matrix Generation Time: %.4f ms", render_data.matrix_generate_time);
    _ = c.ImGui_Text("Matrix Upload Time: %.4f ms", render_data.upload_to_ubo_time);
    _ = c.ImGui_Text("Render Time: %.4f ms", render_data.render_time);
    _ = c.ImGui_Text("UI Generation Time: %.4f ms", window_data.ui_generate_time);
    _ = c.ImGui_Text("UI Draw Time: %.4f ms", window_data.ui_draw_time);
    _ = c.ImGui_Separator();
    _ = c.ImGui_Text("Triangles: %d", render_data.triangle_count);
    _ = c.ImGui_Text("Window Dimensions: %dx%d", render_data.width, render_data.height);
    _ = c.ImGui_Separator();
    _ = c.ImGui_Text("Camera Control: %b", window_data.mouse_grab);
    _ = c.ImGui_Separator();
    _ = c.ImGui_Text("View Azimuth: %f", render_data.view_azimuth);
    _ = c.ImGui_Text("View Elevation: %f", render_data.view_elevation);
    _ = c.ImGui_Separator();
    // Shader toggle button
    if (c.ImGui_Button("Toggle Shader")) {
        render_data.use_changed_shader = !render_data.use_changed_shader;
    }
    _ = c.ImGui_SameLine();
    if (!render_data.use_changed_shader) {
        _ = c.ImGui_Text("Basic Shader");
    } else {
        _ = c.ImGui_Text("Changed Shader");
    }

    _ = c.ImGui_Separator();
    _ = c.ImGui_Text("Field of View: %f", render_data.field_of_view);
    // _ = c.ImGui_SliderInt("##FOV", &render_data.field_of_view, 40, 150);
     _ = c.ImGui_SliderFloat("##FOV", &render_data.field_of_view, 40, 150);
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