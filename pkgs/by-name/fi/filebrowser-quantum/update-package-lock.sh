#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nodejs_22 wget npm-lockfile-fix
version="v0.7.9-beta"

echo Selected filebrowser version: $version
echo "[1/5]: Fetching package.json from repo..."
rm -f {package,package-lock}.json
wget https://raw.githubusercontent.com/gtsteffaniak/filebrowser/refs/tags/${version}/frontend/package.json

req() {
    npm install --package-lock-only $*
}

echo "[2/5]: Generate package-lock, install dependencies that need explicit adding" 
req @tsconfig/node22 lodash-es dayjs autoprefixer
req pinia jwt-decode js-base64 material-icons
req pretty-bytes filesize tus-js-client utif video.js
req videojs-mobile-ui videojs-hotkeys

req @vue/tsconfig vue-final-modal vue-reader vue-demi
req @chenfengyuan/vue-number-input@2 @intlify/unplugin-vue-i18n
req vue-toastification@next

req @vitejs/plugin-legacy terser

# The troublemaker. Do this one last
#req vue-toastification --force --legacy-peer-deps
echo "[3/5] Run npm update..."
#npm update --package-lock-only

echo "[4/5] Running npm-lockfile-fix..."
npm-lockfile-fix ./package-lock.json
#echo "[5/6] Calculating package-lock hash..."
#prefetch-npm-deps ./package.lock.json



echo "[5/5] Cleanup (rm package.json)..." 
#rm package.json
echo "Done!"


