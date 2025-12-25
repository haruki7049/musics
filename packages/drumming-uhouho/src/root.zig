const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;
const Composer = lightmix.Composer;
const WaveInfo = Composer.WaveInfo;

const Parts = @import("./parts.zig");

pub fn generate(allocator: std.mem.Allocator, comptime options: Options(type)) Wave {
    const introduction: Wave = Parts.Introduction.generate(allocator, .{
        .utils = options.utils,

        .bpm = options.bpm,
        .amplitude = options.amplitude,

        .sample_rate = options.sample_rate,
        .channels = options.channels,
    });

    return introduction;
}

pub fn Options(comptime Utils: type) type {
    return struct {
        utils: Utils,

        bpm: usize,
        amplitude: f32,

        sample_rate: usize,
        channels: usize,
    };
}
