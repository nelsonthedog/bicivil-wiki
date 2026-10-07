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
     --restrict-file-names=windows --no-parent --reject-regex '[?](do|idx|rev|tab_details|tab_files|image|media)=' -e robots=off --quiet "http://127.0.0.1:$PORT/" || true
[ -f index.html ] || { echo "build failed: no index.html"; exit 1; }
rm -f feed.php lib/exe/taskrunner*
# give scripts a .js extension so GitHub Pages serves the right content type
for f in lib/exe/js.php@* lib/exe/jquery.php@*; do mv "$f" "$f.js"; done
find . -name '*.html' -print0 | xargs -0 sed -i -E \
  -e 's#(src="(\.\./)*lib/exe/(js|jquery)\.php@[^"]*)"#\1.js"#g' \
  -e 's#<script[^>]*taskrunner[^>]*></script>##g' \
  -e 's#</head>#<style>.secedit,.editbutton_section{display:none}</style></head>#' \
  -e 's#<div class="no">.*taskrunner[^<]*</div>##g'
touch .nojekyll
echo "Built $(find . -name "*.html" | wc -l) pages into $ROOT/preview"
