{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchNpmDeps,
  buildNpmPackage,

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
    inherit version src;

        # Thank you pkgs/by-name/di/dim/package.nix for this solution
    postPatch = ''
      ln -s ${./package-lock.json} package-lock.json
      ln -s ${./package-lock.json} frontend/package-lock.json
    '';

    pname = "filebrowser-quantum-frontend";

    # pkgs/by-name/el/element-desktop/keytar/default.nix
    #npmDeps = fetchNpmDeps {
    #  src = "${src}/frontend";
    #  sourceRoot = "frontend";
    #  hash = "sha256-QFmq+ZMBLwNSgYIOtWeVhVMZk2qHjZ9MMJOFgzQaTVY=";
    #};

    npmRoot = "frontend";
    npmBuildScript = "build";

    nodejs = nodejs_22;
    makeCacheWritable = true;
    
    #forceGitDeps = true;
    npmFlags = [ "--legacy-peer-deps" ];
    #npmDeps = fetchNpmDeps {
    #    name = "fbq-${version}-npm-deps";
    #    inherit src;
    #    
    #    
    #    postPatch = "ln -s ${./package-lock.json} package-lock.json";
#
    #    #configurePhase = "cd frontend";
    #    hash = "sha256-QFmq+ZMBLwNSgYIOtWeVhVMZk2qHjZ9MMJOFgzQaTVY=";
    #  };

    npmDepsHash = "sha256-QFmq+ZMBLwNSgYIOtWeVhVMZk2qHjZ9MMJOFgzQaTVY=";



  });

in
buildGoModule {
  pname = "filebrowser";
  inherit version src;

  vendorHash = "sha256-Jce90mvNzjElCtEMQSSU3IQPz+WLhyEol1ktW4FG7yk=";

  #excludedPackages = [ "tools" ];
  FILEBROWSER_NO_EMBEDED=true;
  #CGO_ENABLED=1;
  tags = [""];
  preBuild = ''
    FILEBROWSER_GENERATE_CONFIG=true go run .
    cp generated.yaml backend/http/public/config.generated.yaml

    cp -r ${frontend}/dist backend/http
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
