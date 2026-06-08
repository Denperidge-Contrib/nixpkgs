{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  gnused,
  jq,
  curl,
  git,
}:

stdenv.mkDerivation rec {
  pname = "retrodeck";
  version = "0.10.9b";

  src = fetchFromGitHub {
    owner = "RetroDECK";
    repo = "RetroDECK";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-xsmUpxJ8J9x/LNUiE3772Z8ezs9HPVEqvYRjR/Xu6Gw=";
  };

  components = fetchFromGitHub {
    owner = "RetroDECK";
    repo = "components";
    hash = "sha256-ZWXwf5KMm73ZoyO0PJL71LnDF2YODrgFS49QNhMKYj0=";
    rev = "main-20260529-1747";
  };
  CICD = true;

  buildInputs = [
    bash
    gnused
    jq
    curl
    git
  ];

  patchPhase = ''
    runHook prePatch
    sed "s#/bin/bash#${bash}/bin/bash#" -i automation_tools/fetch_components.sh
        
    runHook postPatch
  '';

  buildPhase = ''
    runHook preBuild

    mkdir -p retrodeck
    echo "${version}" > retrodeck/version
    cp retrodeck/version version

    ln -s ${components}/ components

    runHook postBuild
  '';

  meta = {
    description = "Retrodeck";
    homepage = "https://www.libretro.com/";
    license = lib.licenses.mit;
    teams = [ lib.teams.libretro ];
    platforms = lib.platforms.all;
  };
}
