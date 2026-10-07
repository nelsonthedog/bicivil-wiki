#!/usr/bin/env bash
# Builds a read-only static copy of the wiki into ./preview using DokuWiki itself.
# Needs: php, curl, wget. Usage: scripts/build-static.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
PORT=8099
trap 'kill $PID 2>/dev/null || true; rm -rf "$WORK"' EXIT

curl -sSL -o "$WORK/dw.tgz" https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz
mkdir "$WORK/dw" && tar xzf "$WORK/dw.tgz" -C "$WORK/dw" --strip-components=1
cd "$WORK/dw"
rm -rf data/pages data/media
cp -r "$ROOT/content/pages" data/pages
cp -r "$ROOT/content/media" data/media
cp "$ROOT/conf/local.php" conf/local.php
cp "$ROOT/conf/userstyle.css" conf/userstyle.css
mkdir -p data/media/wiki && cp "$ROOT/content/media/wiki/logo.svg" data/media/wiki/ 2>/dev/null || true
cat >> conf/local.php <<'PHP'
// static build overrides: no logins/editing/search in the published copy
$conf['useacl'] = 0;
$conf['userewrite'] = 1;
$conf['useslash'] = 1;
$conf['disableactions'] = 'login,register,edit,source,revisions,diff,backlink,subscribe,profile,resendpwd,admin,media,search,recent,export_raw,export_xhtml,export_xhtmlbody,index';
PHP

php -S 127.0.0.1:$PORT -t "$WORK/dw" "$ROOT/scripts/router.php" >"$WORK/php.log" 2>&1 &
PID=$!
sleep 2

rm -rf "$ROOT/preview"; mkdir "$ROOT/preview"
cd "$ROOT/preview"
wget --mirror --page-requisites --convert-links --adjust-extension --no-host-directories \
     --restrict-file-names=windows --no-parent --reject-regex '[?](do|idx|rev|tab_details|tab_files|image)=' -e robots=off --quiet "http://127.0.0.1:$PORT/" || true
[ -f index.html ] || { echo "build failed: no index.html"; exit 1; }
rm -f feed.php lib/exe/taskrunner*
# give scripts a .js extension so GitHub Pages serves the right content type
for f in lib/exe/js.php@* lib/exe/jquery.php@*; do mv "$f" "$f.js"; done
find . -name '*.html' -print0 | xargs -0 sed -i -E \
  -e 's#(src="(\.\./)*lib/exe/(js|jquery)\.php@[^"]*)"#\1.js"#g' \
  -e 's#<script[^>]*taskrunner[^>]*></script>##g' \
  -e 's#</head>#<style>.secedit,.editbutton_section{display:none}</style></head>#' \
  -e 's#<div class="no">.*taskrunner[^<]*</div>##g'
# logo: use the real file instead of the fetch.php URL (works offline, any depth)
cp "$ROOT/content/media/wiki/logo.svg" logo.svg 2>/dev/null || true
find . -name '*.html' | while read -r f; do
  depth=$(printf '%s' "$f" | tr -cd / | wc -c); prefix=""
  for ((i=1; i<depth; i++)); do prefix="../$prefix"; done
  sed -i -E "s#src=\"[^\"]*logo\.svg[^\"]*\"#src=\"${prefix}logo.svg\"#g" "$f"
done
rm -rf lib/exe/fetch.php* _media
touch .nojekyll
echo "Built $(find . -name "*.html" | wc -l) pages into $ROOT/preview"
