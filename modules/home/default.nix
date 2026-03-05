{
  config,
  pkgs,
  userConfig,
  ...
}: {
  imports = [
    ./bash.nix
    ./dircolors.nix
    ./direnv.nix
    ./dotfiles.nix
    ./gh.nix
    ./neovim.nix
    ./nixgl.nix
    ./openclaw.nix
    ./secrets.nix
    ./spicetify.nix
    ./tmux.nix
    ./tools.nix
    ./xdg.nix
    ./zoxide.nix
    ./zsh.nix
  ];

  home = {
    inherit (userConfig) username;
    homeDirectory =
      if pkgs.stdenv.isDarwin
      then "/Users/${config.home.username}"
      else "/home/${config.home.username}";

    stateVersion = "25.11";
    enableNixpkgsReleaseCheck = false;

    activation.updateDotfilesSubmodules =
      config.lib.dag.entryAfter ["writeBoundary"] ''
        DOTFILES_DIR="$HOME/.dotfiles"
        if [ -d "$DOTFILES_DIR/.git" ]; then
          ${pkgs.git}/bin/git -C "$DOTFILES_DIR" submodule update --init --recursive 2>/dev/null || true
        fi
      '';
  };
}
