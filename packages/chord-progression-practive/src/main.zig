const std = @import("std");
const lightmix = @import("lightmix");
const practice = @import("chord-progression-practice");

const Wave = lightmix.Wave;
const Scale = practice.Scale;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const wave: Wave = practice.generate(allocator, .{
        .bpm = 110,
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
    var result = std.ArrayList(f32).init(original_wave.allocator);

    var max_volume: f32 = 0.0;
    for (original_wave.data) |sample| {
        if (sample > max_volume)
            max_volume = sample;
    }

    for (original_wave.data) |sample| {
        const volume: f32 = 1.0 / max_volume;

        const new_sample: f32 = sample * volume;
        try result.append(new_sample);
    }

    return Wave{
        .data = try result.toOwnedSlice(),
        .allocator = original_wave.allocator,

        .sample_rate = original_wave.sample_rate,
        .channels = original_wave.channels,
        .bits = original_wave.bits,
    };
}
