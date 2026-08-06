# react+nginx

Dockerized **React** application, built into static assets and served by **Nginx**.

This service is one of three frontend/backend apps in the parent [Docker-Learning](../README.md) project, sitting behind a shared gateway nginx.

## How it works

- Base image: `node:22-alpine`, with `nginx` installed on top
- Installs JS dependencies (`npm install`) and copies in the app source (`react-app/`)
- Runs `npm run build` to produce a production build (`dist/`)
- Removes nginx's default config, replaces it with this project's `nginx.conf`
- Copies the built static files (`dist/*`) into `/usr/share/nginx/html`
- Starts nginx in the foreground to serve the app

This is a single-stage build (Node is used both to build the app and to run nginx afterward — the image isn't slimmed down to a separate runtime stage).

## Files

| File            | Purpose                                                   |
|-----------------|--------------------------------------------------------------|
| `Dockerfile`    | Installs deps, builds the React app, configures nginx to serve it |
| `nginx.conf`    | Serves static files, with SPA fallback routing              |
| `react-app/`    | React application source and `package.json`                 |

## Nginx routing (inside this container)

```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

This is the standard **single-page-app fallback**: any route that doesn't match a real file falls back to `index.html`, letting client-side routing (e.g. React Router) handle the path.

## Build & run standalone

```bash
docker build -t react-app .
docker run -p 8082:80 react-app
```

Then visit `http://localhost:8082`.

> Normally this service isn't run standalone — it's built and orchestrated via the parent project's `docker-compose.yml`, with the shared gateway nginx routing traffic to it.

## Notes / things to double check before deploying

- Since this is a single-stage build, the final image still carries the full Node toolchain even though only nginx + static files are needed at runtime. Switching to a multi-stage build (Node to build → plain `nginx:alpine` to serve) would produce a much smaller final image.
- Make sure `react-app/.dockerignore` excludes `node_modules` and `dist` from the build context so they aren't copied in stale from the host.
