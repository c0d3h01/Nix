{pkgs, ...}: {
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.symbols-only
    cascadia-code

    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
  ];
}
