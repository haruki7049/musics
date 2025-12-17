const std = @import("std");
const lightmix = @import("lightmix");
const seventh_chords = @import("seventh-chords");

const Wave = lightmix.Wave;
const Scale = @import("./scale.zig");
const Synths = @import("./synths.zig");
const Generators = @import("./generators.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const wave: Wave = seventh_chords.generate(allocator, .{
        .scale = Scale,
        .synths = Synths,
        .generators = Generators,

        .bpm = 125,
        .amplitude = 1.0,

        .sample_rate = 44100,
        .channels = 1,
        .bits = 16,
    }).filter(normalize);
    defer wave.deinit();

    var file = try std.fs.cwd().createFile("result.wav", .{});
    defer file.close();

    try wave.write(file);

    try wave.debug_play();
}

fn normalize(original_wave: Wave) !Wave {
    const allocator = original_wave.allocator;
    var result: std.array_list.Aligned(f32, null) = .empty;

    var max_volume: f32 = 0.0;
    for (original_wave.data) |sample| {
        if (sample > max_volume)
            max_volume = sample;
    }

    for (original_wave.data) |sample| {
        const volume: f32 = 1.0 / max_volume;

        const new_sample: f32 = sample * volume;
        try result.append(allocator, new_sample);
    }

    return Wave{
        .data = try result.toOwnedSlice(allocator),
        .allocator = allocator,

        .sample_rate = original_wave.sample_rate,
        .channels = original_wave.channels,
        .bits = original_wave.bits,
    };
}
