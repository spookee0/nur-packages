# The linter for the configuration files coding agents read: AGENTS.md,
# CLAUDE.md, SKILL.md, hooks and MCP configs. A broken one fails silently, which
# is why it is worth a build gate.
{
  lib,
  rustPlatform,
  rustc,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "agnix";
  version = "0.60.3";

  src = fetchFromGitHub {
    owner = "agent-sh";
    repo = "agnix";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XXrt9bgWLMPgsdiIp88SajpQpQ6nbSfGWu2WtHk2q8c=";
  };

  cargoHash = "sha256-wA2xnizHT5OuKOasxMYya/eJHWD0JaGUTYZpVcsEOFc=";

  # The workspace root is a test-only crate; the binary lives in agnix-cli.
  # The LSP server and the WASM crate are not built here.
  cargoBuildFlags = ["--package" "agnix-cli"];
  cargoInstallFlags = ["--package" "agnix-cli"];

  # Telemetry is a cargo feature that is off by default, and the binary works
  # with no network. `agnix --version` is the smoke test.
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/agnix" --version
    runHook postInstallCheck
  '';

  meta = {
    description = "Linter and LSP for AI coding assistant configuration files";
    homepage = "https://github.com/agent-sh/agnix";
    license = with lib.licenses; [mit asl20];
    # The workspace is edition 2024 and requires rustc 1.91. The 25.05 leg of
    # the CI matrix carries an older toolchain, where the package is broken
    # rather than a failed build.
    broken = lib.versionOlder rustc.version "1.91";
    mainProgram = "agnix";
    sourceProvenance = [lib.sourceTypes.fromSource];
  };
})
