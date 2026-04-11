{pkgs, ...}: {
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";

    defaultOptions = [
      "--preview-window=right:55%:wrap:border-sharp"
      "--preview='${pkgs.bat}/bin/bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || cat {}'"

      "--bind=ctrl-a:first"
      "--bind=ctrl-g:last"

      "--bind=ctrl-j:preview-down"
      "--bind=ctrl-k:preview-up"
      "--bind=ctrl-u:preview-top"
      "--bind=ctrl-b:preview-bottom"

      "--color=bg+:#3c3836,bg:#32302f,spinner:#fb4934,hl:#928374"
      "--color=fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#fb4934"
      "--color=marker:#fb4934,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934"
    ];

    fileWidgetOptions = [
      "--preview='${pkgs.bat}/bin/bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || cat {}'"
    ];

    changeDirWidgetOptions = [
      "--preview='${pkgs.eza}/bin/eza --tree --color=always --icons --level=2 {} 2>/dev/null'"
    ];
  };
}
