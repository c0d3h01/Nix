{
  # Add Flathub manually with `flatpak remote-add` if Flatpak is enabled.
  services.flatpak.enable = false;
  environment.sessionVariables.XDG_DATA_DIRS = ["/var/lib/flatpak/exports/share"];
}
