# Published REA package, adapted from yzua/nixos-config/packages/rea.
# No upstream installer, no TypeScript build, no lifecycle scripts.
{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  nodejs_24,
  importNpmLock,
  autoPatchelfHook,
}:
let
  lock = builtins.fromJSON (builtins.readFile ./package-lock.json);
  version = lock.packages."".version;
in
stdenvNoCC.mkDerivation {
  pname = "rea-agents";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/rea-agents/-/rea-agents-${version}.tgz";
    hash = "sha256-IJWKZtuhoBHlCkhr65Rjo0MSjtNoyYT5QGU2LBP1H5A=";
  };

  # The lock is a runtime-only projection of the release lock. It keeps the
  # exact versions, URLs and integrities; dev entries and the root
  # devDependencies are removed. See README.md for the regeneration command.
  npmDeps = importNpmLock {
    package = lock.packages."";
    packageLock = lock;
  };

  nativeBuildInputs = [
    nodejs_24
    importNpmLock.npmConfigHook
    autoPatchelfHook
  ];

  buildInputs = [ (lib.getLib stdenv.cc.cc) ];

  # Frida's optional install script downloads a prebuilt binding. Keep
  # lifecycle scripts off; the compiled dist and Linux PTY addon are enough.
  npmFlags = [ "--ignore-scripts" ];
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/rea" "$out/bin"
    cp -r \
      dist bridge scripts skills native third_party licenses \
      package.json README.md DISCLAIMER.md THIRD_PARTY_NOTICES.md LICENSE \
      "$out/lib/rea/"
    cp -r node_modules "$out/lib/rea/"

    # npm only patches package scripts. The launcher is copied by hand, so
    # give it an absolute Node shebang. This keeps the command usable from
    # clients that start with a minimal PATH.
    patchShebangs "$out/lib/rea/scripts"

    # A symlink is deliberate. rea setup records the path of the launcher it
    # was invoked through. A wrapper that execs the store script would bake
    # the store path into ~/.pi/agent/mcp.json; a symlink keeps the stable
    # profile path (/etc/profiles/per-user/$USER/bin/rea) in the registration.
    ln -s ../lib/rea/scripts/rea.mjs "$out/bin/rea"
    ln -s rea "$out/bin/rea-agents"

    runHook postInstall
  '';

  meta = {
    description = "Local reverse-engineering CLI and MCP server";
    homepage = "https://github.com/morluto/rea";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "rea";
  };
}
