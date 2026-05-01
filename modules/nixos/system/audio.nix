{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    pavucontrol
    pamixer
  ];

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

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # media-session.enable = true;
  };
}
