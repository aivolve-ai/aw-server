# AIVOLVE central aw-server

```bash
git clone --recurse-submodules git@github.com:aivolve-ai/aw-server.git /root/apps/aw-server
cd /root/apps/aw-server && docker compose up -d --build     # aw-server on 127.0.0.1:5600
```

nginx (`deploy/nginx/`):
- `monitor.aivolve.ai.conf` → `/etc/nginx/sites-available/`, `aw-server-proxy.conf` → `/etc/nginx/snippets/`
- Admin login: `htpasswd -B -c /etc/nginx/aw-server.htpasswd admin`
- Everything needs the admin login except what the watchers on employee PCs send
  (`GET /api/0/info`, `POST` create bucket / heartbeat / events).

Employee PC: in `aw-client.toml` set `[server] hostname = "monitor.aivolve.ai"` and `port = "80"`.
