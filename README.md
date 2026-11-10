# Stube

The *Stube* is the cozy room where everyone in a German-speaking home ends up. Stube is that room for your household, whether that's a family, a WG or friends living together.

A shared shopping list everyone sees live, with a history of who added, changed or checked off what. Everyone joins with a link or QR code. No accounts. Self-hosted with one Docker container, the way Home Assistant works.

## Run it

You need Docker with Compose.

```sh
git clone https://github.com/lucaArchidiacono/stube.git
cd stube
docker compose up -d --build
docker compose logs stube | grep "setup code"
```

Open Stube with the address the others in your household will use too, like `http://192.168.1.20:8080`, not `localhost`: invite links point to the address you opened it with. Create the household with the setup code, then invite the others from Household → Invite someone.

- **Port:** change `"8080:80"` in `compose.yaml`.
- **From anywhere:** with Tailscale, run `tailscale serve --bg 8080` on the server. Behind your own proxy or tunnel, let it handle HTTPS and forward `X-Forwarded-Proto`.
- **Updates:** `git pull && docker compose up -d --build`. The database updates itself on start.

### Backups

Everything lives in the `storage` volume: the databases and the server's secret key. Keep backups private.

```sh
# Back up into stube-backup.tgz
docker compose stop stube
docker compose run --rm --no-deps --user root -v "$PWD":/backup --entrypoint tar stube czf /backup/stube-backup.tgz -C /rails/storage .
docker compose start stube

# Restore from stube-backup.tgz
docker compose stop stube
docker compose run --rm --no-deps --user root -v "$PWD":/backup --entrypoint sh stube -c "rm -rf /rails/storage/* && tar xzf /backup/stube-backup.tgz -C /rails/storage && chown -R 1000:1000 /rails/storage"
docker compose start stube
```

## Develop

Needs the Ruby version in `.ruby-version`.

```sh
bin/setup   # install gems, prepare the database, start the server
bin/dev     # the app on http://localhost:3000, the setup code is in the output
bin/ci      # style, security checks and tests
```

## License

[AGPL-3.0](LICENSE)
