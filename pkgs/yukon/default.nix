{
  lib,
  buildPythonApplication,
  fetchFromGitHub,
  stdenv,
  setuptools,
  setuptools-git-versioning,
}:
buildPythonApplication rec {
  pname = "yukon";
  version = "2023.3.45";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "OpenCyphal";
    repo = "yukon";
    rev = "refs/tags/${version}";
    sha256 = "sha256-wsQzm2toLyzEuE4Zh9mmcjwW46WggFVpa70OXqHMNjU=";
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
