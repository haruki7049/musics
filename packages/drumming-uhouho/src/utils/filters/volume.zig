const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;

pub const decayOptions = struct {
    start_point: usize = 0,
};

pub fn decay(original: Wave, options: decayOptions) !Wave {
    const allocator = original.allocator;
    var result: std.array_list.Aligned(f32, null) = .empty;

    for (original.data, options.start_point..) |data, n| {
        const i = original.data.len - n;
        const volume: f32 = @as(f32, @floatFromInt(i)) * (1.0 / @as(f32, @floatFromInt(original.data.len)));

        const new_data = data * volume;
        try result.append(allocator, new_data);
    }

    return Wave{
        .data = try result.toOwnedSlice(allocator),
        .allocator = allocator,

        .sample_rate = original.sample_rate,
        .channels = original.channels,
    };
}

pub const cutAttackOptions = struct {
    start_point: usize = 1,
    length: usize = 100,
};

pub fn cut_attack(original_wave: Wave, options: cutAttackOptions) !Wave {
    const allocator = original_wave.allocator;
    var result: std.array_list.Aligned(f32, null) = .empty;

    for (original_wave.data, options.start_point..) |data, n| {
        if (n < options.length) {
            const percent: f32 = @floatFromInt(n / options.length);
            try result.append(allocator, percent * data);

            continue;
        }

        try result.append(allocator, data);
    }

    return Wave{
        .data = try result.toOwnedSlice(allocator),
        .allocator = allocator,

        .sample_rate = original_wave.sample_rate,
        .channels = original_wave.channels,
    };
}
