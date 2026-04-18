{pkgs, ...}: {
  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings.dns_enabled = true;
    dockerCompat = true;
    dockerSocket.enable = true;

    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = ["--all" "--volumes"];
    };
  };

  environment.systemPackages = with pkgs; [
    podman-compose
    docker-buildx
    kubectl
  ];
}
