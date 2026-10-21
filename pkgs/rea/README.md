# rea-agents

Pinned upstream REA CLI and MCP server. The package consumes the compiled npm
artifact, so no upstream installer and no TypeScript build are involved.

## Pinned artifacts

- `rea-agents 6.7.0` from the npm registry.
- `package-lock.json` is a runtime-only projection of the release lock at
  `rea-agents-6.7.0`. It keeps runtime versions, URLs and integrities, and
  removes dev entries plus the root `devDependencies`.
- Node is `nodejs_24` (24.21.0 on the current nixpkgs).
- The Linux PTY addon is patched against the Nix compiler runtime by
  `autoPatchelfHook`.

The upstream npm tarball omits `package-lock.json`, so the lock is vendored
next to this file. `importNpmLock` fetches dependencies by their upstream
integrity hashes.

## Update

1. Pick the release tag, for example `rea-agents-6.7.0`.
2. Regenerate the runtime lock projection:

   ```bash
   version=6.7.0
   nix shell nixpkgs#curl nixpkgs#jq -c bash -c "
     curl -fsSL 'https://raw.githubusercontent.com/morluto/rea/rea-agents-$version/package-lock.json' \
       | jq 'del(.packages[\"\"].devDependencies) | .packages |= with_entries(select(.value.dev != true))' \
       > pkgs/rea/package-lock.json
   "
   ```

3. Update the source hash in `default.nix`:

   ```bash
   nix store prefetch-file --hash-type sha256 \
     "https://registry.npmjs.org/rea-agents/-/rea-agents-$version.tgz"
   ```

4. Build and smoke-test:

   ```bash
   nix build .#rea
   ./result/bin/rea --version
   ./result/bin/rea doctor --json
   ```

Do not update only the version in the lock. The runtime dependency set can
change between releases.

## Notes

- `rea update` is intentionally not used. The Nix package owns the executable.
  Update it through this repository and rebuild the system.
- `rea setup` records the launcher path it was invoked through. Run setup via a
  stable profile path, for example
  `/etc/profiles/per-user/$USER/bin/rea setup --client pi`, not through a store
  path.
- The optional Frida Node binding is not built because its install script
  downloads a prebuilt binary. The frida workflow reports the binding as
  unavailable. If it is needed, fetch the matching prebuilt
  `frida-v<version>-napi-v8-linux-x64.tar.gz` and unpack it into
  `$out/lib/rea/node_modules/frida/build` in `postInstall`.
- `rea doctor` reports NixOS as an unsupported host because upstream only lists
  apt, dnf and pacman families. This gates the automated Hopper installer, not
  the Ghidra provider. Ghidra checks pass when a supported JDK is on `PATH` or
  `JAVA_HOME`.
