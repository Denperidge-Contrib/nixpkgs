{
  stdenv,
  lib,
  fetchFromGitHub,
  rustPlatform,
  meson,
  pkg-config,
  cmake,
  hwdata,
  libx11,
  wayland,
  vulkan-loader,
  pipewire,
  wayland-scanner,
  wayland-protocols,
  libxcb,
  libxdamage,
  libxfixes,
  libxcomposite,
  libxcursor,
  libxrender,
  libxext,
  libxxf86vm,
  libxtst,
  libxres,
  libxmu,
  libxi,
  libxkbcommon,
  libdrm,
  systemd,
  libcap,
  SDL2,
  libavif,
  libinput,
  pixman,
  seatd,
  xwayland,
  libxcb-wm,
  lcms2,
  libxcb-errors,
  libdecor,
  glslang,
  luajit,
  v4l-utils,
  ninja,
  libliftoff,
  git,
  python3,
  gbenchmark,
  nix-update-script,
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
  gamescope = fetchFromGitHub {
    owner = "davidawesome02-backup";
    repo = "gamescope";
    rev = "e8b5a00b810f080aafb3b401c7e656957dfe695e";
    hash = "sha256-EE3Qr0JX9OY4DhgON+f2F67t6DtBqmyEK9kwSIX+kFc=";
    fetchSubmodules = true;
  };
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
    meson
    pkg-config
    cmake
    ninja
    glslang
    v4l-utils
    git
  ];
  buildInputs = [
    libx11
    hwdata
    wayland
    vulkan-loader
    pipewire
    wayland-scanner
    wayland-protocols
    libxcb
    libxdamage
    libxfixes
    libxcomposite
    libxcursor
    libxrender
    libxext
    libxxf86vm
    libxtst
    libxres
    libxmu
    libxi
    libxkbcommon
    libdrm
    systemd
    libcap
    SDL2
    libavif
    libinput
    pixman
    seatd
    xwayland
    libxcb-wm
    lcms2
    libxcb-errors
    libdecor
    luajit
    libliftoff
    gbenchmark
    python3
  ];

  cargoHash = "sha256-uVR/t4m/L9qaOabw2kaAT5oebsqxYYbZyXEZLBZtiYE=";

  # Compile-time environment variables for where to find assets needed at runtime
  env = {
    #POLARIS_WEB_DIR = "${polaris-web}/share/polaris-web";
    #POLARIS_SWAGGER_DIR = "${placeholder "out"}/share/polaris-swagger";
  };

  preBuild = ''
     ln -s ${glm} deps/gamescope/subprojects/glm
     ln -s ${stb} deps/gamescope/subprojects/stb
    cat deps/gamescope/subprojects/glm/meson.build
    

    echo ln -s ${gamescope} deps/gamescope
    ls deps/gamescope/subprojects/
    echo meow
    ls deps/gamescope/subprojects/glm
    
    cd deps/gamescope

    
    meson setup build/
    ninja -C build/
    #popd
  '';

  postInstall = ''
  '';


  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Self-host your music collection, and access it from any computer and mobile device";
    longDescription = ''
      Polaris is a FOSS music streaming application, designed to let you enjoy your music collection
      from any computer or mobile device. Polaris works by streaming your music directly from your
      own computer, without uploading it to a third-party. There are no  kind of premium version.
      The only requirement is that your computer stays on while it streams your music!
    '';
    homepage = "https://github.com/agersant/polaris";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pbsds ];
    platforms = lib.platforms.unix;
    mainProgram = "partydeck";
  };
}

