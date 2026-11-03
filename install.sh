#!/usr/bin/env bash
# Set up this machine from the dotfiles repo.
#
#   ./install.sh              link configs + set GNOME shortcuts
#   ./install.sh --packages   also install nvim, ghostty, zellij, ulauncher, fonts
#
# Safe to re-run. Any existing config that isn't already a link into this
# repo is moved aside to <name>.backup-<timestamp> before linking.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Not $XDG_CONFIG_HOME: gsettings/dconf also reads that, so overriding it
# would make the shortcut code see an empty list. Override this for testing.
CONFIG="${DOTFILES_CONFIG_DIR:-$HOME/.config}"
STAMP="$(date +%Y%m%d-%H%M%S)"

say()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!! \033[0m %s\n' "$*"; }

# link <source in repo> <target on disk>
link() {
    local src="$1" dst="$2"
    if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
        echo "   ok       $dst"
        return
    fi
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        mv "$dst" "$dst.backup-$STAMP"
        echo "   backup   $dst -> $dst.backup-$STAMP"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    echo "   linked   $dst"
}

install_packages() {
    say "Installing packages (needs sudo)"
    sudo apt-get update
    sudo apt-get install -y git curl neovim ghostty wl-clipboard fonts-firacode software-properties-common

    if ! command -v ulauncher >/dev/null; then
        sudo add-apt-repository -y ppa:agornostal/ulauncher
        sudo apt-get update
        sudo apt-get install -y ulauncher
    fi

    if ! command -v zellij >/dev/null; then
        local arch
        case "$(uname -m)" in
            x86_64)  arch=x86_64 ;;
            aarch64) arch=aarch64 ;;
            *) warn "No zellij build for $(uname -m); install it manually."; return ;;
        esac
        mkdir -p "$HOME/.local/bin"
        curl -fsSL "https://github.com/zellij-org/zellij/releases/latest/download/zellij-$arch-unknown-linux-musl.tar.gz" \
            | tar -xz -C "$HOME/.local/bin" zellij
        echo "   installed zellij -> ~/.local/bin/zellij"
    fi
}

link_configs() {
    say "Linking configs into $CONFIG"
    for dir in nvim ghostty zellij ulauncher; do
        link "$DOTFILES/config/$dir" "$CONFIG/$dir"
    done
    # Link just the one file: autostart/ holds entries from other apps too.
    link "$DOTFILES/config/autostart/ulauncher.desktop" "$CONFIG/autostart/ulauncher.desktop"

    say "Linking shell config into ${DOTFILES_HOME_DIR:-$HOME}"
    link "$DOTFILES/home/.bashrc" "${DOTFILES_HOME_DIR:-$HOME}/.bashrc"
}

# Wallpaper shuffle: script + systemd user timer (changes wallpaper every 15 min).
# The images themselves are NOT in the repo; put them in ~/Pictures/wallpapers.
setup_wallpaper_shuffle() {
    local home="${DOTFILES_HOME_DIR:-$HOME}"
    say "Setting up wallpaper shuffle timer"
    link "$DOTFILES/bin/wallpaper-shuffle" "$home/.local/bin/wallpaper-shuffle"
    for unit in wallpaper-shuffle.service wallpaper-shuffle.timer; do
        link "$DOTFILES/systemd/$unit" "$CONFIG/systemd/user/$unit"
    done

    if ! command -v systemctl >/dev/null || ! systemctl --user show-environment >/dev/null 2>&1; then
        warn "No systemd user session - enable later with: systemctl --user enable --now wallpaper-shuffle.timer"
        return
    fi
    systemctl --user daemon-reload
    systemctl --user enable --now wallpaper-shuffle.timer
    echo "   enabled  wallpaper-shuffle.timer"
    [ -d "$home/Pictures/wallpapers" ] || warn "Copy your images into ~/Pictures/wallpapers (not stored in the repo)."
}

# GNOME custom shortcut. Reuses the slot with the same name if it exists,
# otherwise takes the next free customN slot. Leaves other shortcuts alone.
gnome_shortcut() {
    local name="$1" cmd="$2" binding="$3"
    local schema=org.gnome.settings-daemon.plugins.media-keys
    local base=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings
    local list path="" i=0

    list="$(gsettings get $schema custom-keybindings)"
    for p in $(echo "$list" | tr -d "[]',"); do
        case "$p" in /*) ;; *) continue ;; esac   # skip the "@as" type tag
        if [ "$(gsettings get "$schema.custom-keybinding:$p" name)" = "'$name'" ]; then
            path="$p"
        fi
    done
    if [ -z "$path" ]; then
        while echo "$list" | grep -q "$base/custom$i/"; do i=$((i + 1)); done
        path="$base/custom$i/"
        if [ "$list" = "@as []" ] || [ "$list" = "[]" ]; then
            list="['$path']"
        else
            list="${list%]}, '$path']"
        fi
        gsettings set $schema custom-keybindings "$list"
    fi
    gsettings set "$schema.custom-keybinding:$path" name "$name"
    gsettings set "$schema.custom-keybinding:$path" command "$cmd"
    gsettings set "$schema.custom-keybinding:$path" binding "$binding"
    echo "   shortcut $binding -> $name"
}

set_shortcuts() {
    if ! command -v gsettings >/dev/null; then
        warn "gsettings not found (not GNOME?) - skipping keyboard shortcuts."
        return
    fi
    say "Setting GNOME keyboard shortcuts"
    gnome_shortcut ulauncher 'ulauncher-toggle' '<Control>space'
    gnome_shortcut Ghostty '/usr/bin/ghostty --gtk-single-instance=true --shell-integration-features=ssh-env' '<Control>e'
}

if [ "${1:-}" = "--packages" ]; then install_packages; fi
link_configs
setup_wallpaper_shuffle
set_shortcuts

say "Done."
echo "   - Open nvim once: lazy.nvim installs the plugins pinned in lazy-lock.json."
echo "   - Log out and back in (or run ulauncher) so Ulauncher starts."
echo "   - Open a new terminal (or: source ~/.bashrc) to load the shell config."
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) warn "Add ~/.local/bin to PATH so zellij is found." ;; esac
