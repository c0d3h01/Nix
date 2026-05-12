{
  # flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  services.flatpak.enable = true;
  environment.sessionVariables.XDG_DATA_DIRS = ["/var/lib/flatpak/exports/share"];
}
