# Docker CE from Docker's official apt repo (deb822 format).

tool_installed() { command -v docker >/dev/null; }

tool_install() {
  local codename
  codename=$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
  curl -fsI "https://download.docker.com/linux/ubuntu/dists/$codename/Release" >/dev/null \
    || die "Docker has no repo suite for '$codename' yet - check Docker's install docs"

  apt_install ca-certificates curl
  run install -m 0755 -d /etc/apt/keyrings
  run curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  run chmod a+r /etc/apt/keyrings/docker.asc

  write_file /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $codename
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

  run apt-get update
  apt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  run systemctl enable --now docker
  run usermod -aG docker "$ADMIN_USER"   # root-equivalent; fine on a single-user key-only box
}
