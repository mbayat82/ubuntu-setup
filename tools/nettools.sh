# Network tools (NET_PACKAGES in config.env): net-tools (ifconfig, netstat), dig, mtr, tcpdump, nmap, iperf3, ...

# Always run: apt skips what is installed, and new names added to the list get picked up.
tool_installed() { return 1; }

tool_install() {
  # shellcheck disable=SC2086
  apt_install_available $NET_PACKAGES
}
