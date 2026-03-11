{
  config,
  lib,
  pkgs,
  hostConfig,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.nixos.services.wireshark;
in {
  options.dotfiles.nixos.services.wireshark.enable = mkEnableOption "Wireshark network analyzer";

  config = mkIf cfg.enable {
    users.users.${hostConfig.username}.extraGroups = ["wireshark"];
    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark;
      usbmon.enable = true;
    };
  };
}
