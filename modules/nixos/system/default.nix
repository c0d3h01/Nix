{
  imports = [
    ./appImage.nix
    ./audio.nix
    ./flatpak.nix
    ./fonts.nix
    ./gnome.nix
    ./input.nix
    ./nix-ld.nix
    ./nix.nix
    ./nixpkgs.nix
    ./packages.nix
    ./plasma.nix
    ./printing.nix
    ./secrets.nix
    ./users.nix
    ./xserver.nix
  ];

  # Desktop envrionment toggle
  services.kdeDesktop.enable = false;
  services.gnomeDesktop.enable = true;
}
