# 0001 — JSBSim: two derivations + a python package-set overlay

- Status: accepted
- Date: 2026-08-19

## Context

JSBSim is a C++ flight dynamics model used in three different ways: as the
`JSBSim` CLI (PX4 / ArduPilot SITL), as the `jsbsim` Python module
(gym-jsbsim / simulation), and as a standalone CLI running `.xml` aircraft
configs. We package it in this NUR.

## Decision

Ship two derivations plus an overlay entry:

- `jsbsim` — the C++ library and CLI. It builds `libJSBSim`, the `JSBSim`
  binary and `aeromatic`, and bundles `aircraft`/`engine`/`systems` data with a
  `jsbsim` wrapper that defaults `--root` to the bundled data.
- `jsbsim-python` — the Python module, exposed at the top level as an alias and
  injected into the Python package set as `jsbsim` so
  `python3.withPackages (p: [ p.jsbsim ])` works.

Both derivations share a single `fetchFromGitHub` source pinned to the v1.3.1
tag (Nix deduplicates the fixed-output derivation, so the tarball is fetched
and stored once). Both build the C++ library, because the Python module is a
Cython extension that links `libJSBSim`; the CLI does not need Python, and the
Python module does not need the CLI binary, so neither derivation should drag
in the other's toolchain.

## Consequences

- The Python module is installed as a normal package into `site-packages`, and
  the wheel bundles its own copy of `aircraft`/`engine`/`systems`/`scripts`, so
  `FGFDMExec(None)` resolves its default root directory out of the box.
- PX4 / ArduPilot SITL keeps using the raw `JSBSim` binary; no wrapper
  interferes with them.

## Rejected alternatives

- **Single blob derivation** that builds both the CLI and the Python module.
  Rejected: it would force the Cython + Python toolchain onto every CLI
  consumer, and couple a Python package to a non-Python CLI so that
  `python3.withPackages` could not use it cleanly.
- **Flat-only exposure** (top-level `jsbsim-python` with no package-set entry).
  Rejected: `python3.withPackages` reads the Python package set, so without an
  overlay entry the module would have to be dropped in with
  `pythonPath = [ jsbsim-python ]` by hand, which breaks dependency closure and
  conflicts checking.
