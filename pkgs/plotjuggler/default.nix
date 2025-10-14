{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  wrapQtAppsHook,
  qtsvg,
  qtwebsockets,
  mosquitto,
  libdwarf,
  protobuf,
  zeromq,
  zstd,
  lua,
  lz4,
  nlohmann_json,
  fmt,
  fastcdr,
  sqlite,
  arrow,
  qtimageformats,
  qtdeclarative,
  qtx11extras,
  xorg,
}: let
  data-tamer-src = fetchFromGitHub {
    owner = "PickNikRobotics";
    repo = "data_tamer";
    rev = "1.0.3";
    hash = "sha256-hGfoU6oK7vh39TRCBTYnlqEsvGLWCsLVRBXh3RDrmnY=";
  };
  libmcap-pkg = stdenv.mkDerivation rec {
    pname = "libmcap";
    version = "1.3.0";

    src = fetchFromGitHub {
      owner = "foxglove";
      repo = "mcap";
      rev = "releases/cpp/v${version}";
      sha256 = "sha256-vGMdVNa0wsX9OD0W29Ndk2YmwFphmxPbiovCXtHxF4E=";
    };

    installPhase = ''
      mkdir -p $out/include
      cp -r cpp/mcap/include/mcap $out/include/
    '';
  };
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "plotjuggler";
    version = "3.10.11";

    src = fetchFromGitHub {
      owner = "facontidavide";
      repo = "PlotJuggler";
      tag = finalAttrs.version;
      fetchSubmodules = true;
      sha256 = "sha256-BFY4MpJHsGi3IjK9hX23YD45GxTJWcSHm/qXeQBy9u8=";
    };

    postUnpack = ''
      (
      cd "$sourceRoot"
      mv plotjuggler_plugins/DataStreamMQTT/cmake/FindMosquitto.cmake plotjuggler_plugins/DataStreamMQTT/cmake/FindMOSQUITTO.cmake
      )
    '';

    postPatch = ''
      substituteInPlace cmake/find_or_download_data_tamer.cmake \
      	--replace "URL" "SOURCE_DIR" \
      	--replace "https://github.com/PickNikRobotics/data_tamer/archive/refs/tags/1.0.3.zip" "${data-tamer-src}"

      rm cmake/find_or_download_fmt.cmake
      rm cmake/find_or_download_fastcdr.cmake
      rm cmake/find_or_download_zstd.cmake

      substituteInPlace CMakeLists.txt \
      	--replace "include(cmake/find_or_download_fmt.cmake)" "find_package(fmt REQUIRED)" \
      	--replace "find_or_download_fmt()" ""

      substituteInPlace CMakeLists.txt \
      	--replace "include(cmake/find_or_download_fastcdr.cmake)" "find_package(fastcdr REQUIRED)" \
      	--replace "find_or_download_fastcdr()" ""
      find . -name "CMakeLists.txt" -exec sed -i 's/fastcdr::fastcdr/fastcdr/g' {} +


      cat > plotjuggler_plugins/DataLoadMCAP/CMakeLists.txt << 'EOF'
      cmake_minimum_required(VERSION 3.5)

      set(CMAKE_AUTOUIC ON)
      set(CMAKE_AUTORCC ON)
      set(CMAKE_AUTOMOC ON)

      project(DataLoadMCAP)

      add_library(mcap INTERFACE)
      find_package(zstd REQUIRED)
      find_package(lz4 REQUIRED)

      add_library(dataload_mcap MODULE dataload_mcap.cpp)

      target_link_libraries(
      dataload_mcap PUBLIC Qt5::Widgets Qt5::Xml Qt5::Concurrent plotjuggler_base mcap
      zstd lz4)

      if(WIN32 AND MSVC)
      target_link_options(dataload_mcap PRIVATE /ignore:4217)
      endif()

      install(TARGETS dataload_mcap DESTINATION ''${PJ_PLUGIN_INSTALL_DIRECTORY})
      EOF

      substituteInPlace CMakeLists.txt \
      	--replace-fail "set(PJ_PLUGIN_INSTALL_DIRECTORY bin)" "set(PJ_PLUGIN_INSTALL_DIRECTORY lib/plugins)"
      substituteInPlace plotjuggler_app/mainwindow.cpp \
      	--replace-fail "QCoreApplication::applicationDirPath()" "\"$out/lib/plugins\""
    '';

    cmakeFlags = [
      "-DPLJ_USE_SYSTEM_LUA=ON"
      "-DPLJ_USE_SYSTEM_NLOHMANN_JSON=ON"
    ];

    nativeBuildInputs = [
      cmake
      wrapQtAppsHook
    ];

    buildInputs = [
      qtsvg
      qtwebsockets
      qtimageformats
      qtdeclarative
      qtx11extras

      zeromq
      sqlite
      lua
      nlohmann_json
      fmt
      fastcdr
      lz4
      zstd

      xorg.libX11
      xorg.libxcb
      xorg.xcbutil
      xorg.xcbutilkeysyms

      libmcap-pkg
      libdwarf
      arrow
      mosquitto
      # protobuf
    ];

    meta = {
      description = "The Time Series Visualization Tool";
      homepage = "https://www.plotjuggler.io/";
      license = lib.licenses.mpl20;
      platforms = lib.platforms.unix;
      broken = true;
    };
  })
