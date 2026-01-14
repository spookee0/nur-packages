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
  pkgsWithCmake3_24 =
    import (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/edd361904bce01c258b5bef7a85d94cda9952f3a.tar.gz";
      sha256 = "03bw2pbjbvsgfwa6sqw7yxs7042r6gs4p74zzl3xlgz3zizha52p";
    }) {
      system = pkgs.stdenv.hostPlatform.system;
    };
  cmake-3_24 = pkgsWithCmake3_24.cmake;
in {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib {inherit pkgs;}; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  at32-work-bench = pkgs.libsForQt5.callPackage ./pkgs/at32-work-bench {};
  elf-size-analyze = pkgs.python3Packages.callPackage ./pkgs/elf-size-analyze {};
  openvsp = pkgs.callPackage ./pkgs/openvsp {
    cmake-3_24 = cmake-3_24;
  };
  throne = pkgs.qt6Packages.callPackage ./pkgs/throne {};
}
