{pkgs, ...}: {
  services.printing = {
    enable = false;
    openFirewall = true;
    browsing = true;
    drivers = [pkgs.gutenprint];
  };

  services.avahi = {
    enable = false;
    nssmdns4 = true;
    nssmdns6 = true;
    openFirewall = true;
  };
}
