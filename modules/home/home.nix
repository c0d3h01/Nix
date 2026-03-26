{
  config,
  hostConfig,
  ...
}: {
  home = {
    inherit (hostConfig) username;
    homeDirectory = "/home/${config.home.username}";
    inherit (hostConfig) stateVersion;
    enableNixpkgsReleaseCheck = false;
  };
}
