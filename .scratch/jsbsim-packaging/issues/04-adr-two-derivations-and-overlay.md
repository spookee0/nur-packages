# 04 — ADR: two derivations + overlay

**What to build:** a short ADR in the NUR repo recording why `jsbsim` and `jsbsim-python` are split into two derivations and why the python module is injected into the python package set via an overlay, instead of a single blob or flat-only exposure.

**Blocked by:** 01, 02, 03

**Status:** ready-for-agent

- [ ] ADR written, covering the structure decision
- [ ] ADR records the rejected alternatives (single blob, flat-only) and why
