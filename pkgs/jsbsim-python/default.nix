{
  lib,
  buildPythonPackage,
  src,

  # build-system
  cmake,
  ninja,
  cython,
  numpy,
  scikit-build-core,

  # buildInputs
  expat,
}:
buildPythonPackage (finalAttrs: {
  pname = "jsbsim";
  version = "1.3.1";
  pyproject = true;

  inherit src;

  build-system = [
    cmake
    ninja
    cython
    numpy
    scikit-build-core
  ];

  buildInputs = [
    expat
  ];

  dependencies = [
    numpy
  ];

  # scikit-build-core configures and builds the CMake project itself, so keep
  # the nixpkgs cmake configure phase from running.
  dontUseCmakeConfigure = true;

  cmakeFlags = [
    "-DSYSTEM_EXPAT=ON"
  ];

  # Upstream only ships the pyproject as a .in template that the CMake configure
  # step expands, and it generates __init__.pyi at release time. scikit-build-core
  # needs a real pyproject.toml up front, and the "wheel" CMake component install
  # rule references __init__.pyi, so materialise both before the PEP-517 build.
  postUnpack = ''
    sed "s/\''${PROJECT_VERSION}/${finalAttrs.version}/g" \
      "$sourceRoot/python/pyproject.toml.in" > "$sourceRoot/pyproject.toml"
    # scikit-build-core 0.x predates `sdist.inclusion-mode`, which is
    # irrelevant here anyway: we build a wheel straight from the source tree.
    sed -i '/sdist\.inclusion-mode/d' "$sourceRoot/pyproject.toml"
    : > "$sourceRoot/python/__init__.pyi"
  '';

  pythonImportsCheck = [
    "jsbsim"
  ];

  # The default-root lookup in get_default_root_dir() only searches real
  # site-packages dirs (it is written for pip wheels), so construct with an
  # explicit root derived from the module's own location. This still proves the
  # C++ extension loads and an FDM exec instance is constructible.
  installCheckPhase = ''
    runHook preInstallCheck
    python -c "import jsbsim, os; root = os.path.dirname(jsbsim.__file__); fdm = jsbsim.FGFDMExec(root); assert fdm.get_root_dir() == root"
    runHook postInstallCheck
  '';

  meta = with lib; {
    description = "Python bindings for JSBSim, a multi-platform flight dynamics model";
    homepage = "https://github.com/JSBSim-Team/jsbsim";
    license = licenses.lgpl21Plus;
    platforms = platforms.unix;
  };
})
