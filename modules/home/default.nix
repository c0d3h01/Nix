{
  imports = [
    # Shell and terminal
    ./alacritty.nix
    ./bash.nix
    ./zsh.nix
    ./starship.nix
    ./tmux.nix

    # CLI tools
    ./bat.nix
    ./delta.nix
    ./dircolors.nix
    ./direnv.nix
    ./eza.nix
    ./fd.nix
    ./fzf.nix
    ./htop.nix
    ./lazygit.nix
    ./lsd.nix
    ./ripgrep.nix
    ./zoxide.nix
    ./yt-dlp.nix

    # Development tools
    ./development

    # Git and GitHub
    ./git.nix
    ./gh.nix

    # Editors and terminals
    ./ghostty.nix
    ./kitty.nix
    ./wezterm.nix
    ./nixvim.nix

    # GUI and desktop
    ./gtk.nix
    ./fonts.nix

    # Applications
    ./vesktop.nix
    ./spicetify.nix

    # Core home configuration
    ./home.nix

    # Secrets (optional, requires sops-nix)
    ./secrets.nix

    # Shell enhancements
    ./nix-your-shell.nix
  ];
}
