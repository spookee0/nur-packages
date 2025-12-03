# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: let
  # Pin nixpkgs to a revision that has cmake 3.24.3
  # This commit is from around the time when cmake 3.24.3 was current
  # (before it was updated to 3.25.2 in nixpkgs) [[1]]
  pkgsWithCmake3_27 =
    import (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/cc9458e2b9a56c085a34e3b648300e46a87e94a3.tar.gz";
      sha256 = "0zflafb2srlpjrrw5qi2xhk1d1nx7akvaj3qdjcxqpxvh48xgskx";
    }) {
      system = pkgs.stdenv.hostPlatform.system;
    };
  cmake-3_27 = pkgsWithCmake3_27.cmake;
in {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib {inherit pkgs;}; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  at32-work-bench = pkgs.libsForQt5.callPackage ./pkgs/at32-work-bench {};
  elf-size-analyze = pkgs.python3Packages.callPackage ./pkgs/elf-size-analyze {};
  openvsp = pkgs.callPackage ./pkgs/openvsp {
    inherit cmake-3_27;
  };
  throne = pkgs.qt6Packages.callPackage ./pkgs/throne {};
}
