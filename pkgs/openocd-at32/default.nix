{
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  libtool,
  pkg-config,
  tcl,
  hidapi,
  libusb1,
  libftdi1,
  jimtcl,
  libjaylink,
  libgpiod_1,
  lib,
}:
stdenv.mkDerivation rec {
  pname = "openocd-at32";
  version = "0.11.0-at32-master";

  src = fetchFromGitHub {
    owner = "ArteryTek";
    repo = "openocd";
    rev = "6160aae74742e3a70a2030331cc0563445962fbc";
    hash = "sha256-4Yniyk5CWR9ubCMMtWn0kKMdX/xIcgSuFG003mkZs6I=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    pkg-config
    tcl
  ];

  buildInputs = [
    hidapi
    libusb1
    libftdi1
    jimtcl
    libjaylink
  ] ++ lib.optional stdenv.hostPlatform.isLinux libgpiod_1;

  preConfigure = ''
    autoreconf -if
  '';

  configureFlags = [
    "--disable-werror"
    "--disable-internal-jimtcl"
    "--disable-internal-libjaylink"
    "--enable-stlink"
    "--enable-ftdi"
    "--enable-jtag_vpi"
    "--enable-remote-bitbang"
  ] ++ lib.optional stdenv.hostPlatform.isLinux "--enable-linuxgpiod";

  enableParallelBuilding = true;
  strictDeps = true;

  meta = with lib; {
    description = "OpenOCD with ArteryTek AT32 support";
    mainProgram = "openocd";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
