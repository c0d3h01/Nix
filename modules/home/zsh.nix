{pkgs, ...}: {
  programs.zsh = {

    enable = true;
    autocd = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    completionInit = "autoload -Uz compinit && compinit -C";
    initContent = ''
      export NIXPKGS_ALLOW_UNFREE=1
      source "${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh"
      fpath+=("${pkgs.zsh-completions}/share/zsh/site-functions")
    '';
  };
}
