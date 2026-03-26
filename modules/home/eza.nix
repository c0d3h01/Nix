{
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;

    git = true;
    icons = "never";
    extraOptions = [
      "--group-directories-first"
      "--color=always"
    ];
  };
}
