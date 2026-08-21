{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  setuptools-git-versioning,
}:
buildPythonPackage rec {
  pname = "elf-size-analyze";
  version = "0.2.2";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-arS83cau3PLk1uECwmKUnlts7zy69nrS4Vz02kazCtI=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-git-versioning
  ];

  meta = with lib; {
    description = "Analyze and visualize ELF binary section and symbol sizes";
    homepage = "https://pypi.org/project/elf-size-analyze/";
    license = licenses.free;
    maintainers = with maintainers; [spookee];
    platforms = platforms.unix;
  };
}
