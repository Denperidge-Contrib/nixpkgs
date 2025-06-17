version="v0.7.9-beta"
nix-shell -p nodejs_22 wget --run "wget https://raw.githubusercontent.com/gtsteffaniak/filebrowser/refs/tags/${version}/frontend/package.json && npm update --package-lock-only"
rm package.json
rm -rf node_
