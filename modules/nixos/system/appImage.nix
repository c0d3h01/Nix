{hostProfile, ...}: {
  programs.appimage = {
    enable = hostProfile.isWorkstation;
    binfmt = true;
  };
}
