{pkgs, ...}: {
  users.users.c0d3h01.extraGroups = ["wireshark"];

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
    usbmon.enable = true;
  };
}
