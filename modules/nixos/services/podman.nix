{pkgs, ...}: {
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;

    containers.containersConf.settings = {
      containers.dns_servers = [
        "8.8.8.8"
        "8.8.4.4"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    podman-compose
    docker-buildx
    kubectl
  ];
}
