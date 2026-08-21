# 03 — jsbsim-python + python package-set overlay

**What to build:** the Python module as a package installable via `python3.withPackages (p: [ p.jsbsim ])`, that imports and can construct an FDM exec instance; plus a top-level alias and registration. Reuses the source fetch established in 01.

**Blocked by:** 01 — jsbsim builds and runs

**Status:** deferred — Python module packaging is deferred until the proper
nixpkgs Python packaging shape is understood (see ADR 0001). Revisit this once
that is settled; the `jsbsim-python` derivation and `pythonPackagesExtensions`
overlay design already exist in the ADR but are not wired in.

- [ ] `nix build .#jsbsim-python` succeeds
- [ ] `python3.withPackages (p: [ p.jsbsim ])` -> `import jsbsim` succeeds
- [ ] an FDM exec instance is constructible from the imported module
