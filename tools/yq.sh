# yq (mikefarah, YAML/JSON/XML processor), latest GitHub release binary into /usr/local/bin.

tool_installed() { command -v yq >/dev/null; }

tool_install() {
  local arch tmp
  arch=$(dpkg --print-architecture)   # amd64 or arm64
  tmp=$(mktemp)
  run curl -fsSL "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_$arch" -o "$tmp"
  run install -m 0755 "$tmp" /usr/local/bin/yq
  rm -f "$tmp"
}
