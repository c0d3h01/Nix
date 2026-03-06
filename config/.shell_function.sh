#!/usr/bin/env bash

# Display PATH
path() {
  if command -v bat >/dev/null 2>&1; then
    printf '%s\n' "$PATH" | tr ':' '\n' | command bat --language=bash --style=plain 2>/dev/null || printf '%s\n' "$PATH" | tr ':' '\n'
  else
    printf '%s\n' "$PATH" | tr ':' '\n'
  fi
}

# Extract archives
extract() {
  local file="${1:-}"
  local dir="${2:-.}"
  local file_lc=""

  if [[ -z $file ]]; then
    echo "Usage: extract <archive> [destination]" >&2
    return 1
  fi
  if [[ ! -f $file ]]; then
    echo "Error: '$file' not found" >&2
    return 1
  fi

  file_lc="$(printf '%s' "$file" | tr '[:upper:]' '[:lower:]')"
  case "$file_lc" in
  *.tar.bz2 | *.tbz2) tar -xjf "$file" -C "$dir" ;;
  *.tar.gz | *.tgz) tar -xzf "$file" -C "$dir" ;;
  *.tar.xz | *.txz) tar -xJf "$file" -C "$dir" ;;
  *.tar.zst | *.tzst) tar -xf "$file" -C "$dir" ;;
  *.bz2) bunzip2 -k "$file" ;;
  *.gz) gunzip -k "$file" ;;
  *.tar) tar -xf "$file" -C "$dir" ;;
  *.zip) unzip -q "$file" -d "$dir" ;;
  *.7z) 7z x "$file" -o"$dir" ;;
  *.xz) unxz -k "$file" ;;
  *.zst) unzstd "$file" ;;
  *)
    echo "Error: Unknown format" >&2
    return 1
    ;;
  esac || return 1

  echo "Extracted to '$dir'"
}

# Make dir and cd
mkcd() {
  if [[ -z ${1:-} ]]; then
    echo "Usage: mkcd <dir>" >&2
    return 1
  fi
  mkdir -p "$1" && cd "$1"
}

# Smart make
make() {
  local build_path
  build_path="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  [[ ! -f "$build_path/Makefile" ]] && build_path="."
  command nice -n 19 make -C "$build_path" -j"$(nproc)" "$@"
}

# Docker cleanup
dclean() {
  docker container prune -f
  docker image prune -af
  docker volume prune -f
  echo "Docker cleaned"
}
