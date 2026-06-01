{
  stdenv,
  gcc14,
  fetchFromGitHub,
  git,
  lib,
  unzip,
  makeWrapper,
  # installed by developer
  cmake-3_24,
  swig,
  python3,
  python314Packages,
  doxygen,
  graphviz,
  # bundled, but system libs are ok
  # angelscript, # needs additional packages
  clipper2,
  cminpack,
  cpptest,
  eigen,
  fltk_1_4,
  glew,
  glm,
  # libxml2,
  pkg-config,
  wayland-scanner,
}:
stdenv.mkDerivation rec {
  pname = "openvsp";
  version = "3.50.4";

  src = fetchFromGitHub {
    owner = "OpenVSP";
    repo = "OpenVSP";
    rev = "OpenVSP_${version}";
    hash = "sha256-exwKC0H2odhQStW/W9/7vkoYQefkt6h1dvM3zpT49w8=";
  };

  nativeBuildInputs = [
    gcc14
    cmake-3_24
    python3
    git
    cpptest
    unzip
    pkg-config
    wayland-scanner
    python314Packages.numpy
    makeWrapper
  ];

  # swig & doxygen are not included as the build would fail since it tries to call
  # "swig -doxygen" which fails Make as this is not a valid command.
  # Seems like an upstream problem.
  buildInputs = [
    swig
    doxygen
    graphviz
    # angelscript
    clipper2
    cminpack
    eigen
    fltk_1_4
    glew
    glm
    # libxml2
  ];
  configurePhase = ''
    mkdir -p build buildlibs
    pushd buildlibs
    cmake \
      -DVSP_USE_SYSTEM_ANGELSCRIPT=false \
      -DVSP_USE_SYSTEM_CLIPPER2=true \
      -DVSP_USE_SYSTEM_CMINPACK=true \
      -DVSP_USE_SYSTEM_CODEELI=false \
      -DVSP_USE_SYSTEM_CPPTEST=true \
      -DVSP_USE_SYSTEM_DELABELLA=false \
      -DVSP_USE_SYSTEM_EIGEN=true \
      -DVSP_USE_SYSTEM_EXPRPARSE=false \
      -DVSP_USE_SYSTEM_FLTK=true \
      -DVSP_USE_SYSTEM_GLEW=true \
      -DVSP_USE_SYSTEM_GLM=true \
      -DVSP_USE_SYSTEM_LIBIGES=false \
      -DVSP_USE_SYSTEM_LIBXML2=false \
      -DVSP_USE_SYSTEM_OPENABF=false \
      -DVSP_USE_SYSTEM_PINOCCHIO=false \
      -DVSP_USE_SYSTEM_STEPCODE=false \
      -DVSP_USE_SYSTEM_TRIANGLE=false \
      $src/Libraries \
      -DCMAKE_BUILD_TYPE=Release \

    make -j$cores
    popd

    pushd build
    cmake $src/src/ -DVSP_LIBRARY_PATH=$PWD/../buildlibs -DCMAKE_BUILD_TYPE=Release
    popd
  '';

  buildPhase = ''
    pushd build
    make -j$cores
    make package
    popd
  '';

  installPhase = ''
    pushd build
    mkdir -p $out/bin
    unzip "OpenVSP-${version}-Linux.zip"
    cp -r "OpenVSP-${version}-Linux"/* $out/bin
    popd

    # FLTK 1.4 Wayland backend is experimental and segfaults with
    # "Fatal error no 1 in Wayland protocol: xdg_toplevel".
    # Force the stable X11 backend by default; users can override
    # with FLTK_BACKEND=wayland if desired.
    wrapProgram $out/bin/vsp --set FLTK_BACKEND x11
  '';

  meta = {
    description = "Parametric aircraft geometry tool";
    homepage = "https://openvsp.org/";
    license = lib.licenses.nasa13;
    maintainers = with lib.maintainers; [kekschen];
    mainProgram = "vsp";
  };
}
