{
  lib,
  hostProfile,
  ...
}: let
  inherit (lib) mkIf;
in {
  config = mkIf hostProfile.isWorkstation {
    # Disable PulseAudio in favor of PipeWire
    services.pulseaudio.enable = false;

    # Enable RTKit for real-time audio scheduling
    security.rtkit.enable = true;

    # PipeWire - Modern low-latency audio server
    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;

      # Low-latency configuration for desktop use
      extraConfig.pipewire = {
        "92-low-latency" = {
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.quantum" = 256;
            "default.clock.min-quantum" = 128;
            "default.clock.max-quantum" = 1024;
          };
        };
      };
    };
  };
}
