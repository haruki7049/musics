const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;
const Composer = lightmix.Composer;
const WaveInfo = Composer.WaveInfo;

const Parts = @import("./parts.zig");
const Utils = @import("./utils.zig");

pub fn gen() !Wave(f128) {
    const allocator = std.heap.page_allocator;

    const introduction: Wave(f128) = Parts.Introduction.generate(allocator, .{
        .utils = Utils,

        .bpm = 170,
        .amplitude = 1.0,

        .sample_rate = 44100,
        .channels = 1,
    });

    return introduction;
}
