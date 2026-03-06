#!/usr/bin/env zsh

[[ -o interactive ]] || return

ifsource() { [[ -f "$1" ]] && source "$1"; }

HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=50000
SAVEHIST=50000
[[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"

setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

setopt AUTO_CD
setopt ALWAYS_TO_END
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt NO_FLOW_CONTROL
setopt GLOB_DOTS
setopt EXTENDED_GLOB
setopt COMBINING_CHARS
unsetopt CORRECT CORRECT_ALL

WORDCHARS='${WORDCHARS:s|/||:s|.||:s|-||}'

[[ -d "$HOME/.completions/src" ]] && fpath=("$HOME/.completions/src" $fpath)

_zsh_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
_zcompdump_file="$_zsh_cache_dir/.zcompdump"
[[ -d "$_zsh_cache_dir" ]] || mkdir -p "$_zsh_cache_dir"

autoload -Uz compinit
compinit -C -d "$_zcompdump_file"

if [[ -s "$_zcompdump_file" && ( ! -s "${_zcompdump_file}.zwc" || "$_zcompdump_file" -nt "${_zcompdump_file}.zwc" ) ]]; then
    zcompile "$_zcompdump_file" &!
fi
unset _zsh_cache_dir _zcompdump_file

zstyle ':completion:*' group-name ''
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=244"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

zstyle ':completion:*:git-checkout:*' sort false
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath'
zstyle ':fzf-tab:complete:*:*' fzf-preview 'file -b {} 2>/dev/null'

command_not_found_handler() {
    print -u2 "zsh: command not found: $1"
    return 127
}

ifsource "$HOME/.credentials"

ifsource "$HOME/.autosuggestions/zsh-autosuggestions.plugin.zsh"
ifsource "$HOME/.fzf-tab/fzf-tab.plugin.zsh"
ifsource "$HOME/.fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"

ifsource "$HOME/.config/shell/export.sh"
ifsource "$HOME/.config/shell/function.sh"
ifsource "$HOME/.config/shell/alias.sh"

(( $+commands[direnv] )) && eval "$(direnv hook zsh)"
(( $+commands[starship] )) && eval "$(starship init zsh)"

if (( $+commands[kubectl] )); then
    () {
        local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
        local cache_file="$cache_dir/kubectl-completion.zsh"
        [[ -d "$cache_dir" ]] || mkdir -p "$cache_dir"
        if [[ ! -s "$cache_file" || "$cache_file" -ot "$(command -v kubectl)" ]]; then
            kubectl completion zsh >| "$cache_file" 2>/dev/null
        fi
        [[ -s "$cache_file" ]] && source "$cache_file"
    }
fi

ifsource /etc/profile.d/nix.sh
ifsource "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"

ifsource "$HOME/.local/share/zsh/.zsh_dir_hashes"

if [[ -d "$HOME/.nix-profile/share/fzf" ]]; then
    ifsource "$HOME/.nix-profile/share/fzf/completion.zsh"
    ifsource "$HOME/.nix-profile/share/fzf/key-bindings.zsh"
fi

if [[ -z "${LS_COLORS:-}" && -f "$HOME/.dircolors" ]]; then
    eval "$(dircolors -b "$HOME/.dircolors")"
fi
[[ -n "${LS_COLORS:-}" ]] && zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

if [[ -d "$HOME/.nvm" ]]; then
    export NVM_DIR="$HOME/.nvm"

    _lazy_load_nvm() {
        unset -f _lazy_load_nvm nvm node npm npx pnpm yarn corepack 2>/dev/null
        [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
        [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
    }

    for _nvm_cmd in nvm node npm npx pnpm yarn corepack; do
        eval "${_nvm_cmd}() { _lazy_load_nvm; ${_nvm_cmd} \"\$@\"; }"
    done
    unset _nvm_cmd
fi

if [[ -d "${PYENV_ROOT:-$HOME/.pyenv}" ]]; then
    export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
    [[ -d "$PYENV_ROOT/bin"   && ":$PATH:" != *":$PYENV_ROOT/bin:"*   ]] && PATH="$PYENV_ROOT/bin:$PATH"
    [[ -d "$PYENV_ROOT/shims" && ":$PATH:" != *":$PYENV_ROOT/shims:"* ]] && PATH="$PYENV_ROOT/shims:$PATH"

    if (( $+commands[pyenv] )); then
        pyenv() {
            unset -f pyenv
            eval "$(command pyenv init - zsh)"
            pyenv "$@"
        }
    fi
fi

if [[ -d "$HOME/.rbenv" ]] && (( $+commands[rbenv] )); then
    rbenv() {
        unset -f rbenv
        eval "$(command rbenv init - zsh)"
        rbenv "$@"
    }
fi

if [[ -d "$HOME/.sdkman" ]]; then
    sdk() {
        unset -f sdk
        export SDKMAN_DIR="$HOME/.sdkman"
        [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
        sdk "$@"
    }
fi

if (( $+commands[opam] )); then
    opam() {
        unset -f opam
        eval "$(command opam env --switch=default 2>/dev/null)"
        opam "$@"
    }
fi

if (( $+commands[dotnet] )); then
    _dotnet_zsh_complete() {
        local completions=("$(dotnet complete "$words")")
        reply=( "${(ps:\n:)completions}" )
    }
    compctl -K _dotnet_zsh_complete dotnet
fi

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -e

bindkey '^P' history-search-backward
bindkey '^N' history-search-forward

bindkey '^?' backward-delete-char
bindkey '^H' backward-delete-char
bindkey '^W' backward-kill-word
bindkey '^[^?' backward-kill-word

bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

bindkey '^X^E' edit-command-line
bindkey '^Xe'  edit-command-line

bindkey "${terminfo[kcuu1]:-^[[A}" history-search-backward
bindkey "${terminfo[kcud1]:-^[[B}" history-search-forward
bindkey "${terminfo[kcub1]:-^[[D}" backward-char
bindkey "${terminfo[kcuf1]:-^[[C}" forward-char

bindkey "${terminfo[kLFT5]:-^[[1;5D}" backward-word
bindkey "${terminfo[kRIT5]:-^[[1;5C}" forward-word

bindkey '^[b' backward-word
bindkey '^[f' forward-word

bindkey "${terminfo[khome]:-^[[H}" beginning-of-line
bindkey "${terminfo[kend]:-^[[F}"  end-of-line

bindkey "${terminfo[kdch1]:-^[[3~}" delete-char

KEYTIMEOUT=20

ttyctl -f
