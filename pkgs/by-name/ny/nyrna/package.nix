{
  lib,
  stdenv,
  fetchFromGitHub,
  flutter341,
  wmctrl,
  xdotool,
  libappindicator,
  keybinder3
}:

flutter341.buildFlutterApplication rec {
  pname = "nyrna";
  version = "2.27.0";

  src = fetchFromGitHub {
    owner = "Merrit";
    repo = "nyrna";
    tag = "v${version}";
    hash = "sha256-6mGhr2v0by83MhPnOdwieJqiioydpBbabQiExm1nO/0=";
  };

  preBuild = ''
    packageRun build_runner build --delete-conflicting-outputs
  '';

  postInstall = ''
    wrapProgram $out/bin/nyrna --prefix PATH : "${lib.makeBinPath [ xdotool wmctrl ]}" \
  '';


  customSourceBuilders = {
    hotkey_manager_linux = 
      { src, version, source }: 
      stdenv.mkDerivation {
        pname = "hotkey_manager_linux";
        inherit version src;
        inherit (src) passthru;
        installPhase = ''
          runHook preInstall
          cp --recursive . "$out"
          runHook postInstall
        '';
      };
  };
  
  pubspecLock = lib.importJSON ./pubspec.lock.json;
  gitHashes = lib.importJSON ./git-hashes.json;

  buildInputs = [
    libappindicator
    keybinder3
    wmctrl
    xdotool
  ];

  nativeBuildInputs = [

  ];

  meta = {
    description = " Suspend games and applications";
    homepage = "https://github.com/Merrit/nyrna";
    mainProgram = "nyrna";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [
      denperidge
    ];
  };
}
