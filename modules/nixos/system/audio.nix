{pkgs, ...}: {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;

    # JACK applications
    jack.enable = true;

    # Example session manager; kept disabled while WirePlumber is active.
    # media-session.enable = true;
  };
}
