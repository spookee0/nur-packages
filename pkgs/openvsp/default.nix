{
  stdenv,
  gcc14,
  fetchFromGitHub,
  git,
  lib,
  unzip,
  # installed by developer
  cmake-3_24,
  swig,
  python3,
  doxygen,
  graphviz,
  # bundled, but system libs are ok
  # angelscript, # needs additional packages
  clipper2,
  cminpack,
  cpptest,
  eigen,
  fltk14,
  glew,
  glm,
  # libxml2, # does not compile for some reason
}:
stdenv.mkDerivation rec {
  pname = "openvsp";
  version = "3.46.0";

  src = fetchFromGitHub {
    owner = "OpenVSP";
    repo = "OpenVSP";
    rev = "OpenVSP_${version}";
    hash = "sha256-zSjWSM5+2tYM5uHssR/ECtJcnwkF/rxsj7obmRpIyu4=";
  };

  nativeBuildInputs = [
    gcc14
    cmake-3_24
    python3
    git
    cpptest
    unzip
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
    fltk14
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
      -DVSP_USE_SYSTEM_FLTK=false \
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

    make -j1
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
  '';

  meta = {
    description = "Parametric aircraft geometry tool";
    homepage = "https://openvsp.org/";
    license = lib.licenses.nasa13;
    maintainers = with lib.maintainers; [kekschen];
    mainProgram = "vsp";
  };
}
