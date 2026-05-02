{
  imports = [
    ./appImage.nix
    ./audio.nix
    ./dbus.nix
    ./documentation.nix
    ./earlyoom.nix
    ./flatpak.nix
    ./fonts.nix
    ./gnome.nix
    ./graphical.nix
    ./nix-daemon.nix
    ./nix-ld.nix
    ./nixpkgs.nix
    ./oomd.nix
    ./packages.nix
    ./plasma.nix
    ./printing.nix
    ./scheduler.nix
    ./secrets.nix
    ./systemd.nix
    ./users.nix
    ./xserver.nix
  ];

  # Desktop environment toggle
  services.kdeDesktop.enable = false;
  services.gnomeDesktop.enable = true;
}
