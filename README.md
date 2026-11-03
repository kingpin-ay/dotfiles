# dotfiles

My dev setup on Ubuntu (GNOME, Wayland):

| Tool | Config in repo | Linked to |
|---|---|---|
| Neovim | `config/nvim/` | `~/.config/nvim` |
| Ghostty (terminal) | `config/ghostty/` (+ `harbor-dark` theme) | `~/.config/ghostty` |
| Zellij | `config/zellij/` | `~/.config/zellij` |
| Ulauncher | `config/ulauncher/`, `config/autostart/ulauncher.desktop` | `~/.config/ulauncher`, `~/.config/autostart/ulauncher.desktop` |
| Bash | `home/.bashrc` | `~/.bashrc` |
| Wallpaper shuffle | `bin/wallpaper-shuffle`, `systemd/wallpaper-shuffle.{service,timer}` | `~/.local/bin/`, `~/.config/systemd/user/` |

### Wallpaper shuffle

A systemd user timer picks a random image from `~/Pictures/wallpapers` one
minute after login, then every 15 minutes. `install.sh` links the script and
units and enables the timer.

**The images are not in this repo** (~400 MB). Copy the folder to the new PC
yourself, e.g. from a USB drive or cloud storage, or over the network:

```bash
rsync -a OLD_PC:~/Pictures/wallpapers/ ~/Pictures/wallpapers/
```

Until the folder exists, the script exits quietly.

Useful commands:

```bash
wallpaper-shuffle                                 # change wallpaper now
systemctl --user list-timers wallpaper-shuffle.timer
systemctl --user disable --now wallpaper-shuffle.timer   # turn it off
```

After editing the `.service`/`.timer` files, run `systemctl --user daemon-reload`.

The configs are **symlinked**, so editing `~/.config/nvim/init.lua` or
`~/.bashrc` edits the file in this repo. Commit and push to save the change.

`.bashrc` also loads these if they are installed (each line is skipped
if the tool is missing): nvm (`~/.nvm`), bun (`~/.bun`), and Rust (`~/.cargo`).
`install.sh --packages` does not install them; install them separately.

Pushing this repo to GitHub for the first time: see [PUSH-TO-GITHUB.md](PUSH-TO-GITHUB.md).

`install.sh` also sets these GNOME keyboard shortcuts:

- `Ctrl+Space` → Ulauncher
- `Ctrl+E` → Ghostty

## New machine

```bash
git clone <this-repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh --packages   # installs nvim, ghostty, zellij, ulauncher, Fira Code, then links everything
```

Already have the tools installed? Run `./install.sh` without `--packages`.

Existing configs are moved to `*.backup-<timestamp>`, never deleted. The
script is safe to re-run.

## Saving changes

```bash
cd ~/dotfiles
git add -A && git commit -m "tweak zellij keys" && git push
```

## On another machine, pull updates

```bash
cd ~/dotfiles && git pull
```
