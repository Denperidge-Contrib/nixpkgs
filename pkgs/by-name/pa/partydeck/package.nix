{
  stdenv,
  lib,
  fetchFromGitHub,
  rustPlatform,
  callPackage,
  pkg-config,
  openssl,
  autoPatchelfHook,
  sdl2-compat,
  SDL2,
  ninja,
  meson,
}:

let 
  version = "0.8.5";

  src = fetchFromGitHub {
    owner = "wunnr";
    repo = "partydeck";
    rev = "v${version}";
    hash = "sha256-f5D+VoAzTeWIOhgiBiQTyTeSVRVBDiIxC+y5uwP92gw=";
    fetchSubmodules = true;
  };
  gamescope = callPackage ./gamescope.nix {};
  glm = stdenv.mkDerivation {
    name = "glm";
    src = fetchFromGitHub {
      owner = "g-truc";
      repo = "glm";
      rev = "0af55ccecd98d4e5a8d1fad7de25ba429d60e863";
      hash = "sha256-GnGyzNRpzuguc3yYbEFtYLvG+KiCtRAktiN+NvbOICE=";
    };
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
    mkdir -p $out
    echo "project('glm', 'cpp', version: '1.0.1', license: 'MIT')

    glm_dep = declare_dependency(
      include_directories: include_directories('.')
    )

    meson.override_dependency('glm', glm_dep)" > $out/meson.build
    '';
  };
  stb = stdenv.mkDerivation {
    name = "stb";
    src = fetchFromGitHub {
      owner = "nothings";
      repo = "stb";
      rev = "5736b15f7ea0ffb08dd38af21067c314d6a3aae9";
      hash = "sha256-s2ASdlT3bBNrqvwfhhN6skjbmyEnUgvNOrvhgUSRj98=";
    };
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
    mkdir -p $out
    echo "project('stb', 'c', version : '0.1.0', license : 'MIT')

stb_dep = declare_dependency(
  include_directories : include_directories('.'),
  version             : meson.project_version()
)

meson.override_dependency('stb', stb_dep)" > $out/meson.build
    '';
  };
  #gamescope = stdenv.mkDerivation ( finalAttrs: {
  #  name = "gamescope";
  #  src = "${src}/deps/gamescope";
  #  buildInputs = [ meson ninja ];
  #  buildPhase = ''
  #    runHook preBuild#

   #   runHook postBuild
   # '';
  #});
in rustPlatform.buildRustPackage {
  inherit version src;
  pname = "partydeck";

  nativeBuildInputs = [
    pkg-config
    autoPatchelfHook
  ];

  buildInpts = [
    openssl
    SDL2
    sdl2-compat
  ];

  cargoHash = "sha256-uVR/t4m/L9qaOabw2kaAT5oebsqxYYbZyXEZLBZtiYE=";
  cargoFlags = ["--release"];

  preFetch = ''
  '';

  env = {
    OPENSSL_LIB_DIR = "${lib.getLib openssl}/lib";
    OPENSSL_DIR = "${lib.getDev openssl}";
  };

  preBuild = ''
    ln -s ${gamescope} deps/gamescope
    ls deps/gamescope/
    echo meow
  '';
  # See https://github.com/partydeck/partydeck/blob/v0.8.5/build.sh
  postbuild = ''
    rm -rf build/partydeck
    mkdir -p build/ build/res build/bin && \
    cp target/release/partydeck build/ && \
    cp LICENSE build/ && cp COPYING.md build/thirdparty.txt && \
    cp res/splitscreen_kwin.js res/splitscreen_kwin_vertical.js build/res && \
    cp deps/gamescope/build-gcc/src/gamescope build/bin/gamescope-kbm
  '';

  postInstall = ''
  '';

  meta = {
    description = " A split-screen game launcher for Linux/SteamOS ";
    homepage = "https://github.com/partydeck/partydeck";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ denperidge ];
    platforms = lib.platforms.linux;
    mainProgram = "partydeck";
  };
}

