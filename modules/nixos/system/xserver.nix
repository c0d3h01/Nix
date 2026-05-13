{pkgs, ...}: {
  # X11: Enable GPU acceleration
  services.xserver = {
    enable = true;
    desktopManager.xterm.enable = false;
    excludePackages = [pkgs.xterm];

    # Configure keymap in X11
    xkb.layout = "us";
    xkb.options = "eurosign:e,caps:escape";
  };
}
