{
  lib,
  fetchFromGitHub,
  buildGoModule,
  importNpmLock,
  fetchNpmDeps,
  buildNpmPackage,
  rsync,
  pnpm,
  vite,
  fd,
  qt5,
  nodejs_22,
}:

let
  version = "v0.7.9-beta";
  commitSha = "b5b4c0c43b19706287268dce2ead6ff0f0217710";

  src = fetchFromGitHub {
    owner = "gtsteffaniak";
    repo = "filebrowser";
    rev = "v${version}";
    hash = "sha256-jckwk45pIRrlzZaG3jH8aLq08L5xnrbt4OdwKNS6+nI=";
  };

  frontend = buildNpmPackage (finalAttrs: {
    inherit version;
    src = "${src}/frontend";
    name = "filebrowser-quantum-frontend";

    nativeBuildInputs = [
      nodejs_22
    ];

    nodejs = nodejs_22;
    npmFlags = [ "--legacy-peer-deps" ];
    makeCacheWritable = true;
    dontNpmPrune = true;
    
    # Prevents ENOTCACHED
    npmDeps = importNpmLock {
      npmRoot = ./.;
      packageLock = lib.importJSON "${./package-lock.json}";
      package = lib.importJSON "${./package.json}";
    };
    npmConfigHook = importNpmLock.npmConfigHook;

    # Thank you pkgs/by-name/di/dim/package.nix for this solution
    postPatch = ''
      ln -s ${./package-lock.json} package-lock.json
      cp ${./config.generated.yaml}  ./public/config.generated.yaml
    '';

    buildPhase = ''
    runHook preBuild
    npx vite build
    runHook postBuild
    '';
  });

in
buildGoModule {
  name = "filebrowser-quantum";
  pname = "filebrowser";
  inherit version src;


  nativeBuildInputs = [
    fd
    rsync
  ];
  #sourceRoot = "${src.name}/backend";

  vendorHash = "sha256-Jce90mvNzjElCtEMQSSU3IQPz+WLhyEol1ktW4FG7yk=";

  excludedPackages = [ "tools" ];


  postPatch = ''
    #mkdir http/embed
    cp -r ${frontend}/lib/node_modules/filebrowser-frontend/* frontend/
    
    ls -l 
    echo ééé
    ls config.yaml  # Crashes
    ln -s $(pwd)/http/embed $(pwd)/http/dist
    fd config.yaml
    echo @@@

    # This is seemingly not necessary? It's not done in upstream GH release workflow
    #FILEBROWSER_GENERATE_CONFIG=true go run .
    #cp generated.yaml backend/http/public/config.generated.yaml
  '';

  env = {
    #FILEBROWSER_NO_EMBEDED=false;
    #CGO_ENABLED=1;
    #FILEBROWSER_GENERATE_CONFIG=true;
  };

  ldflags = [
    "-w"
    "-s"
    "-X 'github.com/gtsteffaniak/filebrowser/backend/version.CommitSHA=${commitSha}'"
    "-X 'github.com/gtsteffaniak/filebrowser/backend/version.Version=${version}'"
  ];

  meta = with lib; {
    description = "Filebrowser is a web application for managing files and directories";
    homepage = "https://filebrowser.org";
    license = licenses.asl20;
    maintainers = with maintainers; [ oakenshield ];
    mainProgram = "filebrowser";
  };
}
