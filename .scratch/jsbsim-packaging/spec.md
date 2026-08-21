# Spec: Package JSBSim in the NUR

## Background

JSBSim (https://github.com/JSBSim-Team/jsbsim) is a C++ Flight Dynamics Model (FDM) used by FlightGear, PX4, ArduPilot and gym-jsbsim. It is not packaged in nixpkgs. FlightGear's nixpkgs package vendors its own adapted copy internally, so there is no reusable derivation to extract.

## Goal

Add JSBSim to the personal NUR for two use cases:

- PX4 / ArduPilot SITL (the `JSBSim` CLI executable)
- Standalone CLI use (running `.xml` aircraft configs)

## Decisions

| # | Decision | Outcome |
|---|----------|---------|
| 1 | Scope | CLI. No external C++ dev use |
| 2 | Location | Personal NUR |
| 3 | Structure | One derivation: `jsbsim` (C++ lib + CLI) |
| 4 | Data | Bundle `aircraft`/`engine`/`systems` into `jsbsim` + a `--root` wrapper |
| 5 | Version | v1.3.1 |
| 6 | expat | System libexpat (`SYSTEM_EXPAT=ON`) |

## Non-goals

- Upstreaming to nixpkgs (revisit once the package is proven)
- Building the Julia / Matlab bindings or the Doxygen docs
- External C++ consumers of `libJSBSim` (headers / dev output)

## Notes

- `aeromatic` is built by default and ships in `jsbsim` for free.
- The derivation uses a single source fetch, pinned to the v1.3.1 tag.

## Tickets

See `issues/`.
