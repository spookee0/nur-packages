{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  lib,
  unzip,
  qtbase,
  qscintilla,
  wrapQtAppsHook,
}:
stdenv.mkDerivation rec {
  pname = "at32-work-bench";
  version = "1.2.00";
  arch = "x86_64";

  src =
    if stdenv.hostPlatform.system == "x86_64-linux"
    then
      fetchurl {
        url = "https://www.arterytek.com/download/TOOL/AT32_Work_Bench_Linux-${arch}_V${version}.zip";
        sha256 = "2036ea6b0290b64ba2850b4181ddd21ab020617f0af9e2b6ef587266e5d93b0a";
      }
    else throw "AT32-Workbench is not supported on ${stdenv.hostPlatform.system}";

  nativeBuildInputs = [autoPatchelfHook wrapQtAppsHook unzip];
  buildInputs = [
    stdenv.cc.cc.lib
    qtbase
    qscintilla
  ];

  unpackPhase = ''
    runHook preUnpack
    unzip ${src} "*.deb"
    ar x *.deb
    tar xf data.tar.xz
    rm usr/local/AT32_Work_Bench/*.so*
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mkdir -p $out/opt/artery32/
    mv usr/local $out/opt/artery32/${pname}
    mv usr/share/ $out/
    # fix the path in the desktop file
    substituteInPlace \
      $out/share/applications/AT32_Work_Bench.desktop \
      --replace /usr/local $out/opt/artery32/${pname}
    substituteInPlace \
      $out/share/applications/AT32_Work_Bench.desktop \
      --replace /usr/share $out/share
    # symlink the binary to bin/
    ln -s $out/opt/artery32/${pname}/AT32_Work_Bench/AT32_Work_Bench.sh $out/bin/AT32_Work_Bench.sh
    ln -s $out/opt/artery32/${pname}/AT32_Work_Bench/AT32_Work_Bench $out/bin/AT32_Work_Bench
    runHook postInstall
  '';

  meta = with lib; {
    description = "AT32 MCU graphical configuration software, generates initialization C code";
    homepage = "https://www.arterytek.com/cn/support/index.jsp?index=5";
    # license = licenses.unfree;
    maintainers = with stdenv.lib.maintainers; [spookee];
    platforms = ["x86_64-linux"];
  };
}
