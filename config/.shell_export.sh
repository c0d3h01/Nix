#!/usr/bin/env zsh

export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export MANPAGER="nvim +Man!"
export MANWIDTH=999
export BROWSER="brave-browser"
export DIFFTOOL="icdiff"

export LC_ALL="en_IN.UTF-8"
export LANG="en_IN.UTF-8"

export TERM="xterm-256color"
export COLORTERM="truecolor"

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

export LESS="-R -F -X -i -J --tabs=4"
export LESSHISTFILE="${XDG_STATE_HOME}/less/history"
[[ -d ${LESSHISTFILE:h} ]] || mkdir -p "${LESSHISTFILE:h}"

# export FZF_DEFAULT_OPTS_FILE="$XDG_CONFIG_HOME/fzf/fzfrc"
# export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
# export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

add_to_path() {
  [[ -d $1 && ":$PATH:" != *":$1:"* ]] && export PATH="$1:$PATH"
}

export CC="${CC:-gcc}"
export CXX="${CXX:-g++}"
export CFLAGS="${CFLAGS:--Wall -Wextra -O2 -pipe}"
export CXXFLAGS="${CXXFLAGS:-$CFLAGS}"
export CMAKE_EXPORT_COMPILE_COMMANDS=1
export CMAKE_GENERATOR="${CMAKE_GENERATOR:-Ninja}"
if (($ + commands[ccache])); then
  export USE_CCACHE=1
  export CCACHE_DIR="${XDG_CACHE_HOME}/ccache"
  add_to_path "/usr/lib/ccache/bin"
  add_to_path "/usr/local/opt/ccache/libexec"
fi

export GOPATH="$HOME/.go"
export GOBIN="$GOPATH/bin"
export GOFLAGS="-count=1"
export GOTELEMETRY="off"
export GOTOOLCHAIN="local"
add_to_path "$GOBIN"
add_to_path "/usr/local/go/bin"

export CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"
export RUSTUP_HOME="${RUSTUP_HOME:-$HOME/.rustup}"
export CARGO_INCREMENTAL=1
export CARGO_NET_GIT_FETCH_WITH_CLI=true
add_to_path "$CARGO_HOME/bin"
[[ -f "$CARGO_HOME/env" ]] && source "$CARGO_HOME/env"

export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1
export PIP_REQUIRE_VIRTUALENV=1
export PIPENV_VENV_IN_PROJECT=1
export VIRTUAL_ENV_DISABLE_PROMPT=1
export PYTHON_HISTORY="${XDG_STATE_HOME}/python/history"
[[ -d ${PYTHON_HISTORY:h} ]] || mkdir -p "${PYTHON_HISTORY:h}"
export UV_CACHE_DIR="${XDG_CACHE_HOME}/uv"
export POETRY_HOME="$HOME/.poetry"
export POETRY_VIRTUALENVS_IN_PROJECT=true
add_to_path "$POETRY_HOME/bin"

export NODE_REPL_HISTORY="${XDG_STATE_HOME}/node/history"
[[ -d ${NODE_REPL_HISTORY:h} ]] || mkdir -p "${NODE_REPL_HISTORY:h}"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NPM_CONFIG_CACHE="${XDG_CACHE_HOME}/npm"
export NPM_CONFIG_INIT_AUTHOR_NAME="c0d3h01"
export COREPACK_ENABLE_STRICT=0
add_to_path "$HOME/.npm-global/bin"
export BUN_INSTALL="$HOME/.bun"
add_to_path "$BUN_INSTALL/bin"
export DENO_DIR="${XDG_CACHE_HOME}/deno"
export DENO_INSTALL="$HOME/.deno"
add_to_path "$DENO_INSTALL/bin"

export JAVA_HOME="${JAVA_HOME:-$HOME/Android/jdk}"
export GRADLE_HOME="$HOME/.gradle"
export GRADLE_USER_HOME="$GRADLE_HOME"
export MAVEN_OPTS="-Xmx2g -XX:+TieredCompilation -XX:TieredStopAtLevel=1"
export _JAVA_OPTIONS="-Dawt.useSystemAAFontRendering=true -Dswing.aatext=true"
add_to_path "$JAVA_HOME/bin"
add_to_path "$GRADLE_HOME/bin"
add_to_path "$HOME/.local/share/coursier/bin"
export SDKMAN_DIR="$HOME/.sdkman"

export CHROME_EXECUTABLE="$BROWSER"
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/latest"
export NDK_HOME="$ANDROID_NDK_HOME"
export FLUTTER_HOME="$HOME/Android/flutter"
export FLUTTER_ROOT="$FLUTTER_HOME"
export PUB_CACHE="$HOME/.pub-cache"
add_to_path "$ANDROID_HOME/cmdline-tools/latest/bin"
add_to_path "$ANDROID_HOME/platform-tools"
add_to_path "$ANDROID_HOME/emulator"
add_to_path "$ANDROID_HOME/build-tools/36.1.0"
add_to_path "$NDK_HOME"
add_to_path "$FLUTTER_HOME/bin"
add_to_path "$PUB_CACHE/bin"

export GEM_HOME="${XDG_DATA_HOME}/gem"
export GEM_SPEC_CACHE="${XDG_CACHE_HOME}/gem"
export BUNDLE_USER_HOME="${XDG_CONFIG_HOME}/bundle"
export BUNDLE_USER_CACHE="${XDG_CACHE_HOME}/bundle"
add_to_path "$GEM_HOME/bin"
if [[ -d "$HOME/.rbenv" ]]; then
  export RBENV_ROOT="$HOME/.rbenv"
  add_to_path "$RBENV_ROOT/bin"
  add_to_path "$RBENV_ROOT/shims"
fi

export COMPOSER_HOME="${XDG_CONFIG_HOME}/composer"
export COMPOSER_CACHE_DIR="${XDG_CACHE_HOME}/composer"
add_to_path "$COMPOSER_HOME/vendor/bin"

export DOTNET_ROOT="$HOME/.dotnet"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export NUGET_PACKAGES="${XDG_CACHE_HOME}/nuget"
add_to_path "$DOTNET_ROOT"
add_to_path "$DOTNET_ROOT/tools"

export ZIG_LOCAL_CACHE_DIR="${XDG_CACHE_HOME}/zig"
add_to_path "$HOME/.zig"

export GHCUP_INSTALL_BASE_PREFIX="$HOME"
export CABAL_DIR="$HOME/.cabal"
export STACK_ROOT="$HOME/.stack"
add_to_path "$HOME/.ghcup/bin"
add_to_path "$CABAL_DIR/bin"

add_to_path "$HOME/.luarocks/bin"

export HEX_HOME="${XDG_DATA_HOME}/hex"
export MIX_HOME="${XDG_DATA_HOME}/mix"
add_to_path "$MIX_HOME/escripts"

export OPAMROOT="${XDG_DATA_HOME}/opam"

export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export BUILDKIT_PROGRESS="plain"

export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"
export K9S_CONFIG_DIR="$XDG_CONFIG_HOME/k9s"
export KUBE_EDITOR="$EDITOR"
export HELM_CACHE_HOME="${XDG_CACHE_HOME}/helm"
export HELM_CONFIG_HOME="${XDG_CONFIG_HOME}/helm"
export HELM_DATA_HOME="${XDG_DATA_HOME}/helm"

export TF_CLI_CONFIG_FILE="${XDG_CONFIG_HOME}/terraform/terraformrc"
export TF_PLUGIN_CACHE_DIR="${XDG_CACHE_HOME}/terraform/plugins"
[[ -d $TF_PLUGIN_CACHE_DIR ]] || mkdir -p "$TF_PLUGIN_CACHE_DIR"

export AWS_CONFIG_FILE="${XDG_CONFIG_HOME}/aws/config"
export AWS_SHARED_CREDENTIALS_FILE="${XDG_CONFIG_HOME}/aws/credentials"
export SAM_CLI_TELEMETRY=0

add_to_path "$HOME/.local/share/google-cloud-sdk/bin"

export ANSIBLE_HOME="${XDG_DATA_HOME}/ansible"
export ANSIBLE_CONFIG="${XDG_CONFIG_HOME}/ansible/ansible.cfg"

add_to_path "$HOME/.local/share/solana/install/active_release/bin"
add_to_path "$HOME/.avm/bin"
add_to_path "$HOME/.foundry/bin"

export GIT_PAGER="delta"
((!$ + commands[delta])) && export GIT_PAGER="less"

export GPG_TTY="$(tty)"
export GNUPGHOME="${XDG_DATA_HOME}/gnupg"

export SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-$(gpgconf --list-dirs agent-ssh-socket 2>/dev/null)}"

export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME}/ripgrep/config"
export WGETRC="${XDG_CONFIG_HOME}/wget/wgetrc"

export SQLITE_HISTORY="${XDG_STATE_HOME}/sqlite/history"
export REDISCLI_HISTFILE="${XDG_STATE_HOME}/redis/history"
export PSQL_HISTORY="${XDG_STATE_HOME}/psql/history"
export MYSQL_HISTFILE="${XDG_STATE_HOME}/mysql/history"

export NIX_PATH="$HOME/.nix-defexpr/channels"

add_to_path "$HOME/.local/bin"
add_to_path "$HOME/bin"
