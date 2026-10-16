# Central aw-server for AIVOLVE: aw-webui is built and served by aw-server itself.
# Build from a checkout with submodules: git clone --recurse-submodules ...
FROM node:20-bookworm AS webui
WORKDIR /src
# aw-webui reads its commit hash with git during the build.
COPY .git/modules/aw-webui/ .git/modules/aw-webui/
COPY aw-webui/ aw-webui/
RUN --mount=type=cache,target=/root/.npm make --directory=aw-webui build

FROM python:3.12-slim
WORKDIR /app
COPY . .
COPY --from=webui /src/aw-webui/dist/ aw_server/static/
# Exact versions from poetry.lock (plain pip picks newer peewee/iso8601 that break aw-core).
RUN pip install --no-cache-dir "poetry>=2.3,<3" \
 && poetry config virtualenvs.create false \
 && poetry install --only main --no-interaction --no-ansi \
 && pip uninstall -y poetry && rm -rf aw-webui .git /root/.cache
# aw-core keeps its SQLite DB under the XDG data dir; mount /data as a volume.
ENV XDG_DATA_HOME=/data XDG_CONFIG_HOME=/data/config XDG_CACHE_HOME=/data/cache
VOLUME /data
EXPOSE 5600
# Run from /app so the package with the built static files is imported.
CMD ["python", "-m", "aw_server", "--host", "0.0.0.0", "--port", "5600"]
