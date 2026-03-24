{
  lib,
  pkgs,
  config,
  ...
}: {
  # Handle ACPI events
  services.acpid.enable = true;

  environment.systemPackages = with pkgs; [
    acpi
    powertop
  ];

  boot = {
    kernelModules = ["acpi_call"];

    extraModulePackages = with config.boot.kernelPackages; [
      acpi_call
      cpupower
    ];
  };
}
