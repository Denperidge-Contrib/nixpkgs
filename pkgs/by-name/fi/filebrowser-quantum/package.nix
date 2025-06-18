{
  lib,
  fetchFromGitHub,
  buildGoModule,
  importNpmLock,
  fetchNpmDeps,
  buildNpmPackage,
  pnpm,
  vite,
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

    
    nativeBuildInputs = [
      nodejs_22
      
    ];
    

    buildPhase = ''
    runHook preBuild

    npx vite build

    runHook postBuild
    '';



        # Thank you pkgs/by-name/di/dim/package.nix for this solution
    #postPatch = ''
    #  ln -s ./packageasa.json ..
    #'';

    pname = "f&lebrowser-quantum-frontend";
    dontNpmPrune = true;
    # pkgs/by-name/el/element-desktop/keytar/default.nix
    #npmDeps = fetchNpmDeps {
    #  src = "${src}/frontend";
    #  sourceRoot = "frontend";
    #  hash = "sha256-QFmq+ZMBLwNSgYIOtWeVhVMZk2qHjZ9MMJOFgzQaTVY=";
    #};

    #npmRoot = "frontend";
    #npmWorkspace = "frontend";

    nodejs = nodejs_22;
    makeCacheWritable = true;
    
    
    npmDeps = importNpmLock {
      npmRoot = ./.;
      packageLock = lib.importJSON "${./package-lock.json}";
      package = lib.importJSON "${./package.json}";
    };
    npmConfigHook = importNpmLock.npmConfigHook;
    npmFlags = [ "--legacy-peer-deps" ];
    #npmDepsHash = "sha256-Mv5oj12nddkQTRYTlV+kcCu9biozlTw8Rl1ZYZ0M4rM=";
  });

in
buildGoModule {
  pname = "filebrowser";
  inherit version src;

QT_DEBUG_PLUGINS=1;
  vendorHash = "sha256-Jce90mvNzjElCtEMQSSU3IQPz+WLhyEol1ktW4FG7yk=";

  excludedPackages = [ "tools" ];
  #FILEBROWSER_NO_EMBEDED=true;
  #CGO_ENABLED=1;
  postBuild = ''
    
    FILEBROWSER_GENERATE_CONFIG=true go run .
    cp generated.yaml backend/http/public/config.generated.yaml

    cd backend/http/ && ln -s ${frontend}/dist
    #cp -r ${frontend}/dist backend/http
  '';

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
