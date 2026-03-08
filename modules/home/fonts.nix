{pkgs, ...}: {
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # Nerd Fonts (patched with icons for terminal/starship/eza)
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.symbols-only
    cascadia-code

    # Base fonts
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
  ];
}
