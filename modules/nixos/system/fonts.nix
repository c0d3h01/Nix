{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkForce;
in {
  fonts.packages = with pkgs; [
    corefonts
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig = mkForce {
    enable = true;
    antialias = true;
    subpixel.rgba = "rgb";
    hinting = {
      enable = true;
      style = "slight";
    };
    defaultFonts = {
      sansSerif = ["Noto Sans"];
      serif = ["Noto Serif"];
      monospace = ["Noto Sans Mono"];
      emoji = ["Noto Color Emoji"];
    };
  };
}
