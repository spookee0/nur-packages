{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  fetchurl,
  makeDesktopItem,
  protobuf,
  protoc-gen-go,
  protorpc,
  cmake,
  copyDesktopItems,
  ninja,
  qt6Packages,
  # override if you want to have more up-to-date rulesets
  throne-srslist ?
    fetchurl {
      url = "https://raw.githubusercontent.com/throneproj/routeprofiles/4e18cf5bce7386346fa2ffc299ac0c4c2036e21b/srslist.h";
      hash = "sha256-fNvh/IFfrsmN6rkWp7HoavY/fnABHkZUV+k3LN+GvZ0=";
    },
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "throne";
  version = "xhttp-5b9022c";
  version-singbox = "v1.12.12";

  src = fetchFromGitHub {
    owner = "throneproj";
    repo = "Throne";
    rev = "5b9022cc383cc28af7db5adfda47b9119300ba32";
    hash = "sha256-vadbRJapaI/7vxMBqjFE2SRib6EXdEI+kHO73LfMOcY=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    copyDesktopItems
    ninja
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    qt6Packages.qtbase
    qt6Packages.qttools
  ];

  cmakeFlags = [
    # makes sure the app uses the user's config directory to store it's non-static content
    # it's essentially the same as always setting the -appdata flag when running the program
    (lib.cmakeBool "NKR_PACKAGE" true)
  ];

  patches = [
    # disable suid request as it cannot be applied to throne-core in nix store
    # and prompt users to use NixOS module instead. And use throne-core from PATH
    # to make use of security wrappers
    ./nixos-disable-setuid-request.patch
  ];

  preBuild = ''
    ln -s ${throne-srslist} ./srslist.h
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 Throne -t "$out/share/throne/"
    install -Dm644 "$src/res/public/Throne.png" -t "$out/share/icons/hicolor/512x512/apps/"

    mkdir -p "$out/bin"
    ln -s "$out/share/throne/Throne" "$out/bin/"

    ln -s ${finalAttrs.passthru.core}/bin/Core "$out/share/throne/Core"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "throne";
      desktopName = "Throne";
      exec = "Throne";
      icon = "Throne";
      comment = finalAttrs.meta.description;
      terminal = false;
      categories = ["Network"];
    })
  ];

  passthru.core = buildGoModule {
    pname = "throne-core";
    inherit (finalAttrs) version src;
    sourceRoot = "${finalAttrs.src.name}/core/server";

    patches = [
      # also check cap_net_admin so we don't have to set suid
      ./core-also-check-capabilities.patch
    ];

    proxyVendor = true;
    vendorHash = "sha256-5EW6dpShayAR7UzMfoXAKUdYB5fACKj9/RZcHVIqQk0=";

    nativeBuildInputs = [
      protobuf
      protoc-gen-go
      protorpc
    ];

    # taken from script/build_go.sh
    preBuild = ''
      pushd gen
      protoc -I . --go_out=. --protorpc_out=. libcore.proto
      popd
    '';

    # ldflags and tags are taken from script/build_go.sh
    ldflags = [
      "-w"
      "-s"
      "-X github.com/sagernet/sing-box/constant.Version=${finalAttrs.version-singbox}"
    ];
    tags = [
      "with_clash_api"
      "with_gvisor"
      "with_quic"
      "with_wireguard"
      "with_utls"
      "with_dhcp"
      "with_tailscale"
    ];
  };

  # this tricks nix-update into also updating the vendorHash of throne-core
  passthru.goModules = finalAttrs.passthru.core.goModules;

  meta = {
    description = "Qt based cross-platform GUI proxy configuration manager";
    homepage = "https://github.com/throneproj/Throne";
    license = lib.licenses.gpl3Plus;
    mainProgram = "Throne";
    platforms = lib.platforms.linux;
  };
})
