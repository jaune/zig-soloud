# zig-soloud

Zig bindinds for [Soloud](https://github.com/jarikomppa/soloud).

```zig
    const zig_soloud_dep = b.dependency("zig-soloud", .{ .target = target, .optimize = optimize });

    exe.root_module.addImport("soloud:c", zig_soloud_dep.module("soloud:c"));
    exe.root_module.linkLibrary(zig_soloud_dep.artifact("soloud"));
```
