# 01 — jsbsim builds and runs

**What to build:** the C++ JSBSim package in the NUR, built from the v1.3.1 source with system expat, producing a runnable `JSBSim` binary (plus `aeromatic` and `libJSBSim`) exposed as `.#jsbsim`. This proves the whole pipeline end to end: source fetch, CMake flags, expat linking.

**Blocked by:** None — can start immediately

**Status:** ready-for-agent

- [ ] `nix build .#jsbsim` succeeds
- [ ] the built `JSBSim` binary executes and prints usage
