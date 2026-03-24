{
  inputs,
  self,
  ...
}: {
  imports = [
    inputs.sops.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = "${self}/secrets/default.yaml";
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  };
}
