# ubuntu-setup

Sets up a fresh Ubuntu Server: hardening, firewall, CLI tools, Python (uv), optional Docker/containerlab. Safe to re-run.

```bash
cp config.local.env.example config.local.env   # your values (git-ignored)
sudo ./setup.sh --dry-run                      # preview
sudo ./setup.sh                                # run default stages
sudo ./setup.sh ssh firewall                   # only some stages
sudo ./setup.sh tools                          # install everything in TOOLS
sudo ./setup.sh --tools "uv docker" tools      # only these tools
sudo ./setup.sh storage                        # format + mount DATA_DISK (erases it)
```

- Settings: `config.env` (defaults), `config.local.env` (yours, wins)
- Stages: `stages/`. Tools: `tools/`, one file each
- Add a tool: copy `tools/_template.sh` to `tools/<name>.sh`, add `<name>` to `TOOLS`
- `ssh` stage needs your public key in `~/.ssh/authorized_keys` first (it refuses otherwise)
- Manual: `sudo tailscale up`, `gh auth login`
