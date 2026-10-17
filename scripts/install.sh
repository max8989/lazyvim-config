#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")/.." && pwd -P)"
app_name="${NVIM_APPNAME:-nvim}"
case "$app_name" in
  ""|.|..|*[!a-zA-Z0-9_.-]*) printf 'Invalid NVIM_APPNAME: %s\n' "$app_name" >&2; exit 1 ;;
esac

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
target="$config_home/$app_name"
if [[ -d "$target" ]] && [[ "$(cd "$target" && pwd -P)" == "$repo_dir" ]]; then
  printf 'Already installed: %s\n' "$target"
  exit 0
fi

stamp="$(date -u +%Y%m%dT%H%M%SZ).$$"
for path in \
  "$target" \
  "${XDG_DATA_HOME:-$HOME/.local/share}/$app_name" \
  "${XDG_STATE_HOME:-$HOME/.local/state}/$app_name" \
  "${XDG_CACHE_HOME:-$HOME/.cache}/$app_name"; do
  if [[ -e "$path" || -L "$path" ]]; then
    backup="$path.before-lazyvim.$stamp"
    mv "$path" "$backup"
    printf 'Backed up %s -> %s\n' "$path" "$backup"
  fi
done

mkdir -p "$config_home"
ln -s "$repo_dir" "$target"
printf 'Installed %s -> %s\n' "$target" "$repo_dir"
printf 'Restore plugins with: NVIM_APPNAME=%s nvim --headless "+Lazy! restore" +qa\n' "$app_name"
