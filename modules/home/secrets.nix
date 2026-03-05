{
  inputs,
  self,
  config,
  ...
}: {
  imports = [
    inputs.sops.homeManagerModules.sops
  ];

  sops = {
    defaultSopsFile = "${self}/secrets/default.yaml";
    age.sshKeyPaths = [
      "${config.home.homeDirectory}/.ssh/id_ed25519"
    ];
  };
}
