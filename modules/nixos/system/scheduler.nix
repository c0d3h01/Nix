{hostProfile, ...}: {
  services.scx = {
    enable = hostProfile.isWorkstation;
    scheduler = "scx_lavd";
    extraArgs = [
      "--performance"
    ];
  };
}
