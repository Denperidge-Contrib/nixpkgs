#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nodejs_22 wget npm-lockfile-fix
version="v0.7.9-beta"

echo Selected filebrowser version: $version
echo "[1/5]: Fetching package.json from repo..."
wget https://raw.githubusercontent.com/gtsteffaniak/filebrowser/refs/tags/${version}/frontend/package.json

echo "[2/5]: Generate package-lock, install missing dependencies" 
npm install --package-lock-only \
    @chenfengyuan/vue-number-input@2 \
    @intlify/unplugin-vue-i18n \
    @tsconfig/node22
echo "[3/5] Run npm update..."
npm update --package-lock-only

echo "[4/5] Running npm-lockfile-fix..."
npm-lockfile-fix ./package-lock.json
#echo "[5/6] Calculating package-lock hash..."
#prefetch-npm-deps ./package.lock.json



echo "[5/5] Cleanup (rm package.json)..." 
#rm package.json
echo "Done!"


