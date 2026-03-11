{
  config,
  pkgs,
  hostConfig,
  ...
}: {
  home = {
    inherit (hostConfig) username;
    homeDirectory = "/home/${config.home.username}";
    inherit (hostConfig) stateVersion;
    enableNixpkgsReleaseCheck = false;
  };

  dotfiles.home = {
    shell.zsh.enable = true;
    shell.bash.enable = true;
    shell.starship.enable = true;
    shell.fzf.enable = true;
    shell.bat.enable = true;
    shell.dircolors.enable = true;
    shell.direnv.enable = true;
    shell.eza.enable = true;
    shell.fd.enable = true;
    shell.ripgrep.enable = true;
    shell.zoxide.enable = true;
    shell.lsd.enable = true;

    terminal.tmux.enable = true;
    terminal.zellij.enable = true;

    dev.git.enable = true;
    dev.gh.enable = true;
    dev.lazygit.enable = true;
    dev.delta.enable = true;
    dev.neovim.enable = true;

    editor.nixvim.enable = true;

    features.ghostty.enable = true;
    features.wezterm.enable = false;
    features.alacritty.enable = false;
    features.kitty.enable = false;
    features.spicetify.enable = true;
    features.openclaw.enable = false;
    features.vesktop.enable = true;
    features.chromium.enable = true;
    features.yt-dlp.enable = true;

    fonts.enable = true;
    secrets.enable = true;
    nixgl.enable = true;
  };
}
