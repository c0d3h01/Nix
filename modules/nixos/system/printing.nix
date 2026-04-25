{pkgs, ...}: {
  services.printing = {
    enable = true;
    openFirewall = true;
    browsing = true;
    drivers = [ pkgs.gutenprint ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = true;
    openFirewall = true;
  };
}
