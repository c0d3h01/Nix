# Purpose: Podman rootless container runtime replacing Docker
{
  pkgs,
  hostConfig,
  ...
}: {
  virtualisation.podman = {
    enable = true;

    # Provide docker CLI compat (podman aliased as docker)
    dockerCompat = true;

    # DNS resolution inside rootless containers
    defaultNetwork.settings.dns_enabled = true;

    # Weekly auto-prune of unused images and volumes
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = ["--all" "--volumes"];
    };
  };

  # Rootless podman needs subuid/subgid ranges for user namespaces
  users.users.${hostConfig.username} = {
    autoSubUidGidRange = true;
  };

  environment.systemPackages = with pkgs; [
    podman-compose
    buildah # OCI image builder
    skopeo # container image inspection and transfer
    lazydocker # TUI for container management (works with podman)
  ];
}
