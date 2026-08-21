# 02 — Ship aircraft data + `--root` wrapper

**What to build:** the `jsbsim` package bundles the `aircraft`, `engine` and `systems` data, and a `jsbsim` wrapper that defaults `--root` to the bundled data so a standalone simulation runs out of the box. The raw `JSBSim` binary stays available for PX4 SITL.

**Blocked by:** 01 — jsbsim builds and runs

**Status:** ready-for-agent

- [ ] bundled `aircraft`/`engine`/`systems` data present in the package
- [ ] `jsbsim` wrapper defaults `--root` to the bundled data
- [ ] a user-supplied `--root` overrides the wrapper default
- [ ] a bundled example aircraft loads without "aircraft not found"
