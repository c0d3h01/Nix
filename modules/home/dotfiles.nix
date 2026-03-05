{
  inputs,
  lib,
  userConfig,
  ...
}: let
  inherit (inputs) dotfiles;
  isWorkstation = userConfig.workstation or false;

  configDirs =
    {
      "nvim".source = "${dotfiles}/.config/nvim";
      "shell".source = "${dotfiles}/.config/shell";
      "cargo".source = "${dotfiles}/.config/cargo";
      "gdb".source = "${dotfiles}/.config/gdb";
      "lazygit".source = "${dotfiles}/.config/lazygit";
      "bat".source = "${dotfiles}/.config/bat";
      "fzf".source = "${dotfiles}/.config/fzf";
      "lsd".source = "${dotfiles}/.config/lsd";
      "ripgrep".source = "${dotfiles}/.config/ripgrep";
      "nushell".source = "${dotfiles}/.config/nushell";
      "yt-dlp".source = "${dotfiles}/.config/yt-dlp";
      "nix".source = "${dotfiles}/.config/nix";
      "nixpkgs".source = "${dotfiles}/.config/nixpkgs";
      "pacman".source = "${dotfiles}/.config/pacman";
      "flake8".source = "${dotfiles}/.config/flake8";
      "isort.cfg".source = "${dotfiles}/.config/isort.cfg";
    }
    // lib.optionalAttrs isWorkstation {
      "alacritty".source = "${dotfiles}/.config/alacritty";
      "kitty".source = "${dotfiles}/.config/kitty";
      "ghostty".source = "${dotfiles}/.config/ghostty";
      "wezterm".source = "${dotfiles}/.config/wezterm";
      "VSCodium/User".source = "${dotfiles}/.config/VSCodium/User";
      "starship.toml".source = "${dotfiles}/.config/starship.toml";
      "chrome-flags.conf".source = "${dotfiles}/.config/chrome-flags.conf";
      "chromium-flags.conf".source = "${dotfiles}/.config/chromium-flags.conf";
    };

  rootFiles =
    {
      ".gdbinit".source = "${dotfiles}/.gdbinit";
      ".dircolors".source = "${dotfiles}/.dircolors";
      ".zprofile".source = "${dotfiles}/.zprofile";
      ".gitconfig".source = "${dotfiles}/.gitconfig";
      ".gitignore".source = "${dotfiles}/.gitignore";
      ".gitignore_global".source = "${dotfiles}/.gitignore_global";
      ".gitattributes".source = "${dotfiles}/.gitattributes";
    }
    // lib.optionalAttrs isWorkstation {
      ".tmux.conf".source = "${dotfiles}/.tmux.conf";
    };
in {
  xdg.configFile = configDirs;
  home.file = rootFiles;
}
