{lib, ...}: {
  xdg = lib.mkForce {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
}
