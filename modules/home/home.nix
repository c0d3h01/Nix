{
  config,
  pkgs,
  userConfig,
  ...
}: {
  home = {
    inherit (userConfig) username;
    homeDirectory =
      if pkgs.stdenv.isDarwin
      then "/Users/${config.home.username}"
      else "/home/${config.home.username}";

    stateVersion = "25.11";
    enableNixpkgsReleaseCheck = false;

    activation.updateDotfilesSubmodules = config.lib.dag.entryAfter ["writeBoundary"] ''
      DOTFILES_DIR="$HOME/.dotfiles"
      if [ ! -d "$DOTFILES_DIR/.git" ]; then
        ${pkgs.git}/bin/git clone https://github.com/c0d3h01/dotfiles.git "$DOTFILES_DIR"
      else
        ${pkgs.git}/bin/git -C "$DOTFILES_DIR" pull --rebase
        ${pkgs.git}/bin/git -C "$DOTFILES_DIR" submodule update --init --recursive 2>/dev/null || true
      fi
    '';
  };

  dotfiles.home.features = {
    spicetify.enable = true;
    openclaw.enable = false;
  };
}
