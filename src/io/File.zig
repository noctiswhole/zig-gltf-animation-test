const File = @This();
const sdl3 = @import("sdl3");

contents: [:0]u8,

pub fn init(path: [:0]const u8) !File {
    const contents =  try sdl3.io_stream.loadFile(path);
    return .{
        .contents = contents,
    };
}

pub fn deinit(self: File) void {
    sdl3.free(self.contents);
}