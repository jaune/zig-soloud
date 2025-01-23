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

    const soloud_sources_dep = b.dependency("soloud:sources", .{});

    const soloud_lib = b.addStaticLibrary(.{
        .name = "soloud",
        .target = target,
        .optimize = optimize,
    });

    soloud_lib.linkLibCpp();

    soloud_lib.addIncludePath(soloud_sources_dep.path("include"));

    // TODO: Add option to select features.
    soloud_lib.addCSourceFiles(.{
        .root = soloud_sources_dep.path("src"),
        .files = &[_][]const u8{
            "audiosource/ay/chipplayer.cpp",
            "audiosource/ay/sndbuffer.cpp",
            "audiosource/ay/sndchip.cpp",
            "audiosource/ay/sndrender.cpp",
            "audiosource/ay/soloud_ay.cpp",
            "audiosource/monotone/soloud_monotone.cpp",
            "audiosource/noise/soloud_noise.cpp",
            "audiosource/openmpt/soloud_openmpt.cpp",
            "audiosource/openmpt/soloud_openmpt_dll.c",
            "audiosource/sfxr/soloud_sfxr.cpp",
            "audiosource/speech/darray.cpp",
            "audiosource/speech/klatt.cpp",
            "audiosource/speech/resonator.cpp",
            "audiosource/speech/soloud_speech.cpp",
            "audiosource/speech/tts.cpp",
            "audiosource/tedsid/sid.cpp",
            "audiosource/tedsid/soloud_tedsid.cpp",
            "audiosource/tedsid/ted.cpp",
            "audiosource/vic/soloud_vic.cpp",
            "audiosource/vizsn/soloud_vizsn.cpp",
            "audiosource/wav/dr_impl.cpp",
            "audiosource/wav/soloud_wav.cpp",
            "audiosource/wav/soloud_wavstream.cpp",
            "audiosource/wav/stb_vorbis.c",

            "core/soloud.cpp",
            "core/soloud_audiosource.cpp",
            "core/soloud_bus.cpp",
            "core/soloud_core_3d.cpp",
            "core/soloud_core_basicops.cpp",
            "core/soloud_core_faderops.cpp",
            "core/soloud_core_filterops.cpp",
            "core/soloud_core_getters.cpp",
            "core/soloud_core_setters.cpp",
            "core/soloud_core_voicegroup.cpp",
            "core/soloud_core_voiceops.cpp",
            "core/soloud_fader.cpp",
            "core/soloud_fft.cpp",
            "core/soloud_fft_lut.cpp",
            "core/soloud_file.cpp",
            "core/soloud_filter.cpp",
            "core/soloud_misc.cpp",
            "core/soloud_queue.cpp",
            "core/soloud_thread.cpp",

            "c_api/soloud_c.cpp",

            "filter/soloud_bassboostfilter.cpp",
            "filter/soloud_biquadresonantfilter.cpp",
            "filter/soloud_dcremovalfilter.cpp",
            "filter/soloud_duckfilter.cpp",
            "filter/soloud_echofilter.cpp",
            "filter/soloud_eqfilter.cpp",
            "filter/soloud_fftfilter.cpp",
            "filter/soloud_flangerfilter.cpp",
            "filter/soloud_freeverbfilter.cpp",
            "filter/soloud_lofifilter.cpp",
            "filter/soloud_robotizefilter.cpp",
            "filter/soloud_waveshaperfilter.cpp",
        },
        .flags = &[_][]const u8{},
    });

    b.installArtifact(soloud_lib);

    const soloud_translate = b.addTranslateC(.{
        .root_source_file = soloud_sources_dep.path("include/soloud_c.h"),
        .target = target,
        .optimize = optimize,
    });
    _ = soloud_translate.addModule("soloud:c");

    switch (target.result.os.tag) {
        .macos => {
            soloud_lib.defineCMacro("WITH_COREAUDIO", "1");
            soloud_translate.defineCMacroRaw("WITH_COREAUDIO=1");
            soloud_lib.addCSourceFiles(.{
                .root = soloud_sources_dep.path("src"),
                .files = &[_][]const u8{
                    "backend/coreaudio/soloud_coreaudio.cpp",
                },
                .flags = &[_][]const u8{},
            });
        },
        .windows => {
            soloud_lib.defineCMacro("WITH_WINMM", "1");
            soloud_translate.defineCMacroRaw("WITH_WINMM=1");
            soloud_lib.addCSourceFiles(.{
                .root = soloud_sources_dep.path("src"),
                .files = &[_][]const u8{
                    "backend/winmm/soloud_winmm.cpp",
                },
                .flags = &[_][]const u8{},
            });
            soloud_lib.linkSystemLibrary("Winmm");

            // TODO: Add option to select backend.
            //
            // soloud_lib.defineCMacro("WITH_WASAPI", "1");
            // soloud_translate.defineCMacroRaw("WITH_WASAPI=1");
            // soloud_lib.addCSourceFiles(.{
            //     .root = soloud_sources_dep.path("src"),
            //     .files = &[_][]const u8{
            //         "backend/wasapi/soloud_wasapi.cpp",
            //     },
            //     .flags = &[_][]const u8{},
            // });
            // soloud_lib.linkSystemLibrary("Ole32");
        },
        else => {
            return error.UnsupportedOs;
        },
    }
}
