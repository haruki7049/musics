const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;
const Composer = lightmix.Composer;
const WaveInfo = Composer.WaveInfo;

const Parts = @import("./parts.zig");
const Scale = @import("./scale.zig");
const Synths = @import("./synths.zig");
const Generators = @import("./generators.zig");

pub fn gen() !Wave(f128) {
    const allocator = std.heap.page_allocator;

    const introduction: Wave(f128) = Parts.Introduction.generate(allocator, .{
        .scale = Scale,
        .synths = Synths,
        .generators = Generators,

        .bpm = 125,
        .amplitude = 1.0,

        .sample_rate = 44100,
        .channels = 1,
    });

    return introduction;
}
