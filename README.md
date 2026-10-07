# Bcivil Wiki

DokuWiki for the Bcivil Minecraft server. Pages are plain text files tracked in git.

## Run

```sh
docker compose up -d
```

Open <http://localhost:8080/install.php> and create the admin account (pick the
ACL option, superuser). Then delete `data/dokuwiki/install.php` if prompted.

## Free hosting on GitHub Pages (no server, no commands)

A GitHub Action (`.github/workflows/pages.yml`) builds a read-only static copy of the
wiki from `content/pages/` on every push to `main` and publishes it.

1. Merge this branch into `main`.
2. In the repo go to **Settings > Pages** and set **Source** to **GitHub Actions**.
3. After the Action finishes, the site is at `https://<user>.github.io/bicivil-wiki/`.

To edit: open a file in `content/pages/` on github.com, click the pencil, save.
The site updates in about a minute. The published copy has no login or search;
run the Docker setup above if you need a live, editable wiki.
Preview locally with `scripts/build-static.sh` (output in `site/`).

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
