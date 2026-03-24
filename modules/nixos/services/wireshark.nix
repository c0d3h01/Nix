{
  pkgs,
  hostConfig,
  ...
}: {
  users.users.${hostConfig.username}.extraGroups = ["wireshark"];

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
    usbmon.enable = true;
  };
}
