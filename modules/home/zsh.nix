{pkgs, ...}: {
  programs.zsh = {
    enable = true;

    initContent = ''
      ifsource() { [ -f "$1" ] && source "$1"; }

      ifsource "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
      ifsource "${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh"
      ifsource "${pkgs.zsh-fast-syntax-highlighting}/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
      fpath+=("${pkgs.zsh-completions}/share/zsh/site-functions")

      for f in "$HOME/.config/shell/"*.sh; do
        [ -f "$f" ] && source "$f"
      done

      autoload -Uz compinit && compinit -C
    '';
  };
}
