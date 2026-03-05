{
  programs.direnv = {
    enable = true;
    silent = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
}
