# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

## Packages

| Package | Description | Notes |
| --- | --- | --- |
| `agnix` | Linter for AI coding assistant configuration (`AGENTS.md`, `SKILL.md`, hooks, MCP) | Rust; the CLI only, the LSP and WASM crates are not built |
| `at32-work-bench` | AT32 MCU graphical config tool (generates init C code) | unfree; `x86_64-linux` only |
| `elf-size-analyze` | Analyze and visualize ELF binary section/symbol sizes | Python |
| `jsbsim` | Multi-platform object-oriented flight dynamics model (C++ CLI) | bundles `aircraft`/`engine`/`systems` data |
| `mautrix-telegram` | Matrix-Telegram puppeting bridge (Go/bridgev2) | upstream tag pinned; uses mautrix-go's pure Go `goolm`, not deprecated libolm |
| `openocd-at32` | OpenOCD with ArteryTek AT32 support | `linux` only |
| `openvsp` | Parametric aircraft geometry tool | needs cmake 3.24.3 (pinned) + gcc 14 (`overrideCC`, gcc 15 breaks vendored libs) |
| `rea` | REA reverse-engineering CLI and MCP server | pinned npm artifact; `x86_64-linux` only; Frida binding unbuilt |

## Usage

As a flake input:

```nix
inputs.nur.url = "github:spookee0/nur-packages";

# then, e.g. in home.packages / environment.systemPackages:
inputs.nur.packages.${pkgs.stdenv.hostPlatform.system}.openvsp
inputs.nur.packages.${pkgs.stdenv.hostPlatform.system}.rea
```

As an overlay (adds every package to `pkgs`):

```nix
nixpkgs.overlays = [ (import (inputs.nur + "/overlay.nix")) ];
# then just: pkgs.openvsp
```

Non-flake (`nix-build`):

```bash
nix-build -A openvsp
```
