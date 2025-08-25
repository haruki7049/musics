const std = @import("std");
const lightmix = @import("lightmix");
const seventh_chords = @import("seventh-chords");

const Wave = lightmix.Wave;
const Scale = seventh_chords.Scale;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const wave: Wave = try seventh_chords.generate(allocator, .{
        .bpm = 70,
        .amplitude = 1.0,

        .sample_rate = 44100,
        .channels = 1,
        .bits = 16,
    });
    defer wave.deinit();

    var file = try std.fs.cwd().createFile("result.wav", .{});
    defer file.close();

    try wave.write(file);

    try wave.debug_play();
}
