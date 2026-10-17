#!/usr/bin/env bash
set -euo pipefail
repo_dir="${1:-$(cd "$(dirname "$0")/.." && pwd -P)}"
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT
export XDG_CONFIG_HOME="$work_dir/config space"
export XDG_DATA_HOME="$work_dir/data space"
export XDG_STATE_HOME="$work_dir/state space"
export XDG_CACHE_HOME="$work_dir/cache space"
export NVIM_APPNAME=nvim

mkdir -p "$XDG_CONFIG_HOME" "$work_dir/old config"
ln -s "$work_dir/old config" "$XDG_CONFIG_HOME/nvim"
printf 'original config' > "$work_dir/old config/marker"
for directory in "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME"; do
  mkdir -p "$directory/nvim"
  printf 'original state' > "$directory/nvim/marker"
done

bash "$repo_dir/scripts/install.sh" > "$work_dir/install.log"
[[ "$(cd "$XDG_CONFIG_HOME/nvim" && pwd -P)" == "$repo_dir" ]]
for directory in "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME"; do
  backups=("$directory/nvim".before-lazyvim.*)
  [[ "${#backups[@]}" == 1 && -f "${backups[0]}/marker" ]]
done

bash "$repo_dir/scripts/install.sh" > "$work_dir/second.log"
[[ "$(cat "$work_dir/second.log")" == "Already installed: $XDG_CONFIG_HOME/nvim" ]]
if NVIM_APPNAME=../invalid bash "$repo_dir/scripts/install.sh" > /dev/null 2>&1; then
  printf 'Invalid profile name was accepted\n' >&2
  exit 1
fi
printf 'PASS: installer backup, symlink, path quoting, and idempotency checks\n'
