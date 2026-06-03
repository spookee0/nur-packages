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
  version = "1.2.04";
  arch = "x86_64";
  src =
    if stdenv.hostPlatform.system == "x86_64-linux"
    then
      fetchurl {
        url = "https://www.arterytek.com/download/TOOL/AT32_Work_Bench_Linux-${arch}_V${version}.zip";
        sha256 = "sha256-cA9fr0lHWKuSf/lKdfOV1jd19ixp00D3A7VkYmjneT8=";
      }
    else throw "AT32-Workbench is not supported on ${stdenv.hostPlatform.system}";

  nativeBuildInputs = [autoPatchelfHook unzip wrapQtAppsHook];
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
    cd usr/local/AT32_Work_Bench
    rm *.so* AT32_Work_Bench.sh copylib.sh
    # rm -rf platforms
    cd ../../..
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mkdir -p $out/opt
    mv usr/local $out/opt/${pname}
    mv usr/share/ $out/

    # Create wrapper script
    cat > $out/bin/${pname} <<EOF
    #!/usr/bin/env bash
    mkdir -p \$HOME/.${pname}
    cp -r $out/opt/${pname}/* \$HOME/.${pname}/
    chmod -R +w \$HOME/.${pname}
    cd \$HOME/.${pname}
    exec \$HOME/.${pname}/AT32_Work_Bench/AT32_Work_Bench
    EOF

    substituteInPlace \
      $out/share/applications/AT32_Work_Bench.desktop \
      --replace /usr/local/AT32_Work_Bench/AT32_Work_Bench.sh $out/bin/${pname}
    substituteInPlace \
      $out/share/applications/AT32_Work_Bench.desktop \
      --replace /usr/share $out/share

    chmod +x $out/bin/${pname}
    runHook postInstall
  '';

  meta = with lib; {
    description = "AT32 MCU graphical configuration software, generates initialization C code";
    homepage = "https://www.arterytek.com/cn/support/index.jsp?index=5";
    license = licenses.unfree;
    maintainers = with stdenv.lib.maintainers; [spookee];
    platforms = ["x86_64-linux"];
  };
}
