{hostProfile, ...}: {
  services = {
    printing = {
      enable = hostProfile.isWorkstation;
      openFirewall = hostProfile.isWorkstation;
    };

    avahi = {
      enable = hostProfile.isWorkstation;
      nssmdns4 = true;
      nssmdns6 = true;
      openFirewall = hostProfile.isWorkstation;
    };
  };
}
