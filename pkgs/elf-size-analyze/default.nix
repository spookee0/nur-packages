{
  lib,
  buildPythonPackage,
  fetchPypi,
  stdenv,
  setuptools,
  setuptools-git-versioning,
}:
buildPythonPackage rec {
  pname = "elf-size-analyze";
  version = "0.2.2";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "arS83cau3PLk1uECwmKUnlts7zy69nrS4Vz02kazCtI=";
  };

  nativeBuildInputs = [
    stdenv.cc.cc.lib
    setuptools
    setuptools-git-versioning
  ];

  meta = with lib; {
    license = licenses.free;
  };
}
