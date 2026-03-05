_: {
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    git = true;
    icons = "auto";
    extraOptions = [
      "--group-directories-first"
      "--color=always"
    ];
  };
}
