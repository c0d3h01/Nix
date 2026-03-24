{hostProfile, ...}: {
  services.irqbalance.enable = hostProfile.isWorkstation;
}
