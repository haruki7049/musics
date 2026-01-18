const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;

const Self = @This();

pub fn generate(allocator: std.mem.Allocator, options: Options) Wave(f128) {
    const base_data: []const f128 = generate_closed_high_hat_data(
        options.amplitude,
        allocator,
    );
    defer allocator.free(base_data);

    const result: Wave(f128) = Wave(f128).init(base_data, allocator, .{
        .sample_rate = options.sample_rate,
        .channels = options.channels,
    })
        .filter(attack)
        .filter(decay)
        .filter(decay)
        .filter(decay)
        .filter(decay);

    return result;
}

fn generate_closed_high_hat_data(amplitude: f128, allocator: std.mem.Allocator) []const f128 {
    var result: std.array_list.Aligned(f128, null) = .empty;
    defer result.deinit(allocator);

    var prng = std.Random.DefaultPrng.init(0);
    const rand = prng.random();

    const length: usize = 22050;
    for (0..length) |_| {
        const v: f128 = @as(f128, (rand.float(f64) / 3 - 1.0));
        result.append(allocator, v * amplitude) catch @panic("Out of memory");
    }

    return result.toOwnedSlice(allocator) catch @panic("Out of memory");
}

pub const Options = struct {
    amplitude: f128,

    sample_rate: u32,
    channels: u16,
};

fn decay(original_wave: Wave(f128)) !Wave(f128) {
    var result: std.array_list.Aligned(f128, null) = .empty;

    for (original_wave.samples, 0..) |sample, n| {
        const i = original_wave.samples.len - n;
        const volume: f128 = @as(f128, @floatFromInt(i)) * (1.0 / @as(f128, @floatFromInt(original_wave.samples.len)));

        const new_sample = sample * volume;
        try result.append(original_wave.allocator, new_sample);
    }

    return Wave(f128){
        .samples = try result.toOwnedSlice(original_wave.allocator),
        .allocator = original_wave.allocator,

        .sample_rate = original_wave.sample_rate,
        .channels = original_wave.channels,
    };
}

fn attack(original_wave: Wave(f128)) !Wave(f128) {
    const allocator = original_wave.allocator;
    var result: std.array_list.Aligned(f128, null) = .empty;

    const length: usize = 100;
    for (original_wave.samples, 1..) |sample, n| {
        if (n < length) {
            const percent: f128 = @as(f128, @floatFromInt(n)) / @as(f128, @floatFromInt(length));
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
