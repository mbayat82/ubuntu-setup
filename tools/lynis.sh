# Lynis security audit tool. Run it with: sudo lynis audit system

tool_installed() { pkg_installed lynis; }

tool_install() { apt_install lynis; }
