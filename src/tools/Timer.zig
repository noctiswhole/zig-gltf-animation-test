const Timer = @This();
const sdl3 = @import("sdl3");
const Logger = @import("../io/Logger.zig").makeLogger("Timer");

start_tick: u64 = 0,
stop_tick: u64 = 0,

pub fn init() Timer {
    return .{};
}

pub fn start(self: *Timer) void {
    self.start_tick = get_ticks();
    self.stop_tick = 0;
}

pub fn stop(self: *Timer) void {
    if (self.start_tick == 0) {
        Logger.log("Stopped timer without starting");
    } else {
        self.stop_tick = get_ticks();
    }
}

// Get timer in ms
pub fn get_time(self: Timer) f32 {
    // if (self.start_tick == 0 or self.stop_tick == 0) {
        const difference: f32 = @floatFromInt(@subWithOverflow(self.stop_tick, self.start_tick)[0]);
        return difference / @as(f32, @floatFromInt(sdl3.timer.getPerformanceFrequency())) * 1000;
    // } else {
    //     Logger.log("Tried to get timer duration without having started and stopped the timer");
    //     return 0;
    // }
}

fn get_ticks() u64 {
    return sdl3.timer.getPerformanceCounter();
}