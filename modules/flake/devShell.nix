{inputs, ...}: {
  imports = [
    inputs.devshell.flakeModule
  ];

  perSystem = {
    config,
    pkgs,
    ...
  }: {
    devshells.default = {
      motd = "";

      packages = [
        pkgs.nixd
        pkgs.nil
        pkgs.gnumake
        pkgs.gitMinimal
        pkgs.age
        (pkgs.git-crypt.override {git = pkgs.gitMinimal;})
        pkgs.sops
        config.formatter
        pkgs.nix-output-monitor
      ];
    };
  };
}
