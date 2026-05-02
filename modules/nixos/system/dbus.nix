{pkgs, ...}: {
  services.dbus = {
    enable = true;
    # Use the faster dbus-broker instead of the classic dbus-daemon
    implementation = "broker";
    packages = builtins.attrValues {inherit (pkgs) dconf gcr_4 udisks;};
  };
}
