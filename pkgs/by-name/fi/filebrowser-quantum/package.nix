{
  lib,
  fetchFromGitHub,
  buildGoModule,
  importNpmLock,
  fetchNpmDeps,
  gnumake,
  buildNpmPackage,
  rsync,
  pnpm,
  vite,
  fd,
  qt5,
  nodejs_22,
}:

let
  version = "0.7.9-beta";
  commitSha = "b5b4c0c43b19706287268dce2ead6ff0f0217710";

  src = fetchFromGitHub {
    owner = "gtsteffaniak";
    repo = "filebrowser";
    rev = "v${version}";
    hash = "sha256-o6UoYYULnVgkXN9fNnTTNxF+i9pA7FuV31xfZppXMBE=";
  };

  frontend = buildNpmPackage (finalAttrs: {
    inherit version;
    src = "${src}/frontend";
    name = "filebrowser-quantum-frontend";

    npmDepsHash = "sha256-Lyi8O4rKtybsFhzs32az4AJ/HEnoEo9VuuRtaJ4Jy/0=";
    # Thank you pkgs/by-name/di/dim/package.nix for this solution
    postPatch = ''
      ln -s ${./package-lock.json} package-lock.json
      cp ${./config.generated.yaml}  ./public/config.generated.yaml
    '';

    # Manual invocation for later copying
    buildPhase = ''
    runHook preBuild
    npx vite build
    runHook postBuild
    '';
  });
in
buildGoModule {
  inherit version src;
  pname = "filebrowser-quantum";
  sourceRoot = "${src.name}/backend";

  vendorHash = "sha256-v7hYo2HIKonnNVGwOV8WiaWzo4FNSG5/8Ov3w/ivB+8=";

  excludedPackages = [ "tools" ];

  postPatch = ''
    mkdir http/dist
    cp -r ${frontend}/lib/node_modules/filebrowser-frontend/dist/* http/embed
  '';

  postInstall = ''
    mv $out/bin/backend $out/bin/filebrowser
  '';

  meta = with lib; {
    description = "FileBrowser Quantum provides an easy way to access and manage your files from the web";
    homepage = "https://github.com/gtsteffaniak/filebrowser";
    license = licenses.asl20;
    maintainers = with maintainers; [ denperidge ];
    mainProgram = "filebrowser";
  };
}
