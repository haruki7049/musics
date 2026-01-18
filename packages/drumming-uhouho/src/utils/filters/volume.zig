const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;

pub const decayOptions = struct {
    start_point: usize = 0,
};

pub fn decay(original: Wave(f128), options: decayOptions) !Wave(f128) {
    const allocator = original.allocator;
    var result: std.array_list.Aligned(f128, null) = .empty;

    for (original.samples, options.start_point..) |sample, n| {
        const i = original.samples.len - n;
        const volume: f128 = @as(f128, @floatFromInt(i)) * (1.0 / @as(f128, @floatFromInt(original.samples.len)));

        const new_sample = sample * volume;
        try result.append(allocator, new_sample);
    }

    return Wave(f128){
        .samples = try result.toOwnedSlice(allocator),
        .allocator = allocator,

        .sample_rate = original.sample_rate,
        .channels = original.channels,
    };
}

pub const cutAttackOptions = struct {
    start_point: usize = 1,
    length: usize = 100,
};

pub fn cut_attack(original_wave: Wave(f128), options: cutAttackOptions) !Wave(f128) {
    const allocator = original_wave.allocator;
    var result: std.array_list.Aligned(f128, null) = .empty;

    for (original_wave.samples, options.start_point..) |sample, n| {
        if (n < options.length) {
            const percent: f128 = @floatFromInt(n / options.length);
            try result.append(allocator, percent * sample);

            continue;
        }

        try result.append(allocator, sample);
    }

    return Wave(f128){
        .samples = try result.toOwnedSlice(allocator),
        .allocator = allocator,

        .sample_rate = original_wave.sample_rate,
        .channels = original_wave.channels,
    };
}
