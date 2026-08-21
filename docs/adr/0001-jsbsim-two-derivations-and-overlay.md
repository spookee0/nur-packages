# 0001 — JSBSim packaging (C++ CLI now; Python module deferred)

- Status: accepted (C++ derivation); Python module deferred
- Date: 2026-08-19

## Context

JSBSim (https://github.com/JSBSim-Team/jsbsim) is a C++ Flight Dynamics Model
(FDM) used by FlightGear, PX4, ArduPilot and gym-jsbsim. It is not packaged in
nixpkgs. We package it in this NUR, starting with the C++ CLI and leaving the
Python module for later once the proper packaging shape is settled.

## Decision

Ship one derivation for now:

- `jsbsim` — the C++ library and CLI. It builds `libJSBSim`, the `JSBSim`
  binary and `aeromatic`, and bundles `aircraft`/`engine`/`systems` data with a
  `jsbsim` wrapper that defaults `--root` to the bundled data.

The Python module (`import jsbsim`, gym-jsbsim / simulation use) and its
injection into the Python package set are **deferred**; see issue `03`. The
split into `jsbsim` + `jsbsim-python` derivations and the `pythonPackagesExtensions`
overlay were designed but are not wired in yet, so the structure below is the
intended end state, not the current one.

The derivation uses a single `fetchFromGitHub` source pinned to the v1.3.1 tag.

## Consequences

- PX4 / ArduPilot SITL uses the raw `JSBSim` binary; no wrapper interferes with
  them. Standalone `.xml` aircraft runs work out of the box via the `jsbsim`
  wrapper.
- The Python module is not available from this NUR yet.

## Rejected / deferred alternatives (for when the Python module is packaged)

- **Single blob derivation** that builds both the CLI and the Python module.
  Rejected: it would force the Cython + Python toolchain onto every CLI
  consumer, and couple a Python package to a non-Python CLI so that
  `python3.withPackages` could not use it cleanly. (Deferred, not decided yet.)
- **Flat-only exposure** (top-level `jsbsim-python` with no package-set entry).
  Rejected: `python3.withPackages` reads the Python package set, so without an
  overlay entry the module would have to be dropped in with
  `pythonPath = [ jsbsim-python ]` by hand, which breaks dependency closure and
  conflicts checking. (Deferred, not decided yet.)
