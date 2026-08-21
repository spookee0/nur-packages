{
  stdenv,
  cmake,
  pkg-config,
  expat,
  makeWrapper,
  lib,
  src,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "jsbsim";
  version = "1.3.1";

  inherit src;

  nativeBuildInputs = [
    cmake
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    expat
  ];

  cmakeFlags = [
    "-DSYSTEM_EXPAT=ON"
    "-DBUILD_DOCS=OFF"
    "-DBUILD_PYTHON_MODULE=OFF"
    "-DBUILD_JULIA_PACKAGE=OFF"
    "-DBUILD_MATLAB_SFUNCTION=OFF"
  ];

  postInstall = ''
    mkdir -p "$out/share/jsbsim"
    cp -r "$src"/aircraft "$src"/engine "$src"/systems "$out/share/jsbsim/"
  '';

  # The raw JSBSim binary stays available for PX4/ArduPilot SITL. The lowercase
  # `jsbsim` wrapper defaults --root to the bundled data so a standalone
  # simulation runs out of the box. A user-supplied --root overrides it because
  # JSBSim keeps the last --root seen on the command line.
  postFixup = ''
    makeWrapper "$out/bin/JSBSim" "$out/bin/jsbsim" \
      --add-flags "--root=$out/share/jsbsim"
  '';

  meta = with lib; {
    description = "Multi-platform, general purpose object-oriented flight dynamics model";
    homepage = "https://github.com/JSBSim-Team/jsbsim";
    license = licenses.lgpl21Plus;
    mainProgram = "jsbsim";
    platforms = platforms.unix;
    maintainers = with maintainers; [spookee];
  };
})
