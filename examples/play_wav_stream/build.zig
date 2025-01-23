const std = @import("std");

const BuildOptions = struct {
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
};

pub fn build(
    b: *std.Build,
) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "play_wav_stream",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run play_wav_stream");
    run_step.dependOn(&run_cmd.step);

    const zig_soloud_dep = b.dependency("zig-soloud", .{
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addImport(
        "soloud:c",
        zig_soloud_dep.module("soloud:c"),
    );
    exe.root_module.linkLibrary(zig_soloud_dep.artifact("soloud"));
}
