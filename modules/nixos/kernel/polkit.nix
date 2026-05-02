{
  # Enable polkit so desktop apps and system services can
  # request privileged actions safely without running as root.

  security = {
    polkit.enable = true;
    soteria.enable = true;
  };
}
