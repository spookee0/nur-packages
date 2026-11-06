# The Go/bridgev2 rewrite of the Matrix-Telegram puppeting bridge. nixpkgs
# still carries the Python bridge of the same name, so this derivation is the
# only way to get the current upstream bridge. The NixOS module stays in dots:
# it knows about ginger's secrets, PostgreSQL and host layout.
{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule (finalAttrs: {
  pname = "mautrix-telegram";
  # Upstream reports the calendar release (26.10) but tags it as a semver
  # version. Keep the tag explicit so the derivation mirrors the upstream
  # release page and `--version` agrees with the tag.
  version = "26.10";
  tag = "v0.2610.0";

  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "telegram";
    tag = finalAttrs.tag;
    hash = "sha256-2oHtqtpFhNr+v49nMSe33RGDj+MQV2D/+8JX+YYWi+0=";
  };

  vendorHash = "sha256-JbnlJnCtIKC3rpO2mBa7DvEFeWuq9tpvN9H+MoQ5VV0=";

  # libolm is deprecated and carries known side-channel vulnerabilities. The
  # bridge only needs Matrix E2EE for encrypted portal rooms, and mautrix-go
  # ships a pure Go implementation (goolm) selected by this build tag. This
  # keeps libolm out of the closure for consumers such as dots, which permits
  # no insecure packages.
  tags = ["goolm"];

  # The repository also carries development tools under pkg/gotd/cmd. Install
  # only the bridge binary.
  subPackages = ["cmd/mautrix-telegram"];

  ldflags = [
    "-s"
    "-w"
    "-X"
    "main.Tag=${finalAttrs.tag}"
  ];

  doCheck = false;

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/mautrix-telegram" --version
    runHook postInstallCheck
  '';

  meta = {
    description = "Matrix-Telegram puppeting bridge (Go/bridgev2)";
    homepage = "https://github.com/mautrix/telegram";
    changelog = "https://github.com/mautrix/telegram/blob/${finalAttrs.tag}/CHANGELOG.md";
    license = lib.licenses.agpl3Plus;
    mainProgram = "mautrix-telegram";
    platforms = lib.platforms.linux;
    sourceProvenance = [lib.sourceTypes.fromSource];
  };
})
