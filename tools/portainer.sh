# Portainer CE, bound to loopback only (it mounts the Docker socket).
# Reach it with: ssh -L 9443:127.0.0.1:9443 <user>@<host> -> https://localhost:9443
# Needs docker first, so keep it after docker in TOOLS.

tool_installed() {
  docker ps -a --format '{{.Names}}' 2>/dev/null | grep -qx portainer
}

tool_install() {
  command -v docker >/dev/null || (( DRY_RUN )) || die "portainer needs docker (put docker before it in TOOLS)"
  run docker volume create portainer_data
  run docker run -d --name portainer --restart=always \
    -p 127.0.0.1:9443:9443 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:lts
  log "create the Portainer admin account right away"
}
