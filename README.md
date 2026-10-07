# Bcivil Wiki

DokuWiki for the Bcivil Minecraft server. Pages are plain text files tracked in git.

## Run

```sh
docker compose up -d
```

Open <http://localhost:8080/install.php> and create the admin account (pick the
ACL option, superuser). Then delete `data/dokuwiki/install.php` if prompted.

## Offline preview (just double-click)

Download this repo as a ZIP (green **Code** button > **Download ZIP**), unzip it, and
double-click **`index.html`**. It opens a read-only copy of the wiki in your browser,
no server or install needed. It has no login, search or editing.

The copy lives in `preview/` and is generated from `content/pages/`. After changing
pages, regenerate it with `scripts/build-static.sh` (needs php, curl, wget), or ask Claude to.

## Layout

| Path | Purpose |
|------|---------|
| `content/pages/` | Wiki pages (`guides/claims.txt` = page `guides:claims`) |
| `content/media/` | Uploaded images/files |
| `conf/local.php` | Site title, ACL and other settings |
| `data/` | Runtime state (git-ignored): users, plugins, revisions |

## Customising

- Replace `play.bcivil.example`, Discord link and `//italic//` placeholders in the pages.
- Edit in the browser or directly in `content/pages/` and commit.
- Registration is disabled in `conf/local.php`; staff create users via Admin > User Manager.
- Put a reverse proxy (Caddy/nginx) with HTTPS in front before exposing it publicly.

> Note: the pages and `conf/local.php` were tested on DokuWiki 2026-07-14c via PHP's built-in server. The Docker compose file itself has not been run.
