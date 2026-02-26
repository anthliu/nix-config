# Maintenance Guide: Niri Middle-Click Spatial Navigation Patch

This guide explains how to maintain and update the `niri-middle-click-drag.patch` if it ever fails to apply due to upstream Niri updates.

## How to Detect a Failure
When you run `nixos-rebuild` or `home-manager switch`, Nix will attempt to apply the patch. If the Niri source code has changed significantly, the build will fail with an error like:
```text
error: builder for '/nix/store/...-niri-unstable.drv' failed with exit code 1
...
patching file src/input/mod.rs
Hunk #1 FAILED at 2845.
```

## Maintenance Workflow

If the patch fails, follow these steps to "re-base" it:

### 1. Identify the Target Commit
Check your `flake.lock` or the build log to see which Niri commit is being used. Alternatively, you can find the current source in the Nix store, but it's easier to use Git.

### 2. Manual Resolution
Since you no longer have a local Niri clone, you must create a temporary one to re-align the patch:

```bash
# 1. Clone Niri and checkout the correct version
git clone https://github.com/niri-wm/niri /tmp/niri-fix
cd /tmp/niri-fix
# (Optional: git checkout <commit-id> if you want to be precise)

# 2. Try to apply the existing patch
git apply ~/nix-config/patches/niri-middle-click-drag.patch
```

If `git apply` fails, it will tell you which files are "dirty." You will need to manually re-apply the logic:
- **`src/input/mod.rs`**: Ensure `SpatialMovementGrab::new` receives `event.time_msec()` and middle-clicks don't require `mod_down`.
- **`src/input/spatial_movement_grab.rs`**: Ensure `start_time` is stored and the `button` method enqueues the click into `queue_synthesized_click` instead of calling `pointer.button` directly.
- **`src/niri.rs`**: Ensure the `queue_synthesized_click` field exists in the `Niri` struct.

### 3. Regenerate the Patch
Once the code in `/tmp/niri-fix` is working (and compiles if you have Rust installed):

```bash
git diff > ~/nix-config/patches/niri-middle-click-drag.patch
```

### 4. Update Nix
Nix identifies files by their content when they are in the git repo.
```bash
cd ~/nix-config
git add patches/niri-middle-click-drag.patch
```

## Why this Patch is Complex
This isn't just a "UI tweak." It handles **Wayland click synthesis** and **concurrency deadlocks**. 

> [!CAUTION]
> **Avoid direct dispatch**: Never call `pointer.button()` from inside a `PointerGrab::button` implementation. This is what caused the input freeze. Always use the `queue_synthesized_click` deferral mechanism.

## Future Proofing
The best way to "fix" this forever is to upstream it. If Niri ever adds a mapping for `MiddleClick` in the config that allows a transparent "pass-through" click, this entire patch can be replaced by a few lines of config.
