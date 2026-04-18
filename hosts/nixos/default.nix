{inputs, ...}: let
  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICSjL8HGjiSAnLHupMZin095bql7A8+UDfc7t9XCZs8l"
  ];
in {
  imports = [
    # Disko integration for disk partitioning
    # inputs.disko.nixosModules.disko

    ../filesystems/btrfs.nix
  ];

  users.users = {
    root = {
      hashedPassword = "$y$j9T$KAIygNaHsr4EgJcn2Jto.1$9gK08qEPSw/Fll//2TCe5ijYIqavtnvoundIux8Uy5/";
      openssh.authorizedKeys.keys = sshKeys;
    };

    c0d3h01 = {
      home = "/home/c0d3h01";
      hashedPassword = "$y$j9T$jbMpDi1jashn36Vczb8jO/$E8M0edjvWOZg24Su5bFWaQ5tHcPkwyQ8HdzkAMx0km7";
      openssh.authorizedKeys.keys = sshKeys;
    };

    anon = {
      home = "/home/anon";
      hashedPassword = "$y$j9T$IKXrH64o2Ni7mqraKV6ke/$3FtfHxmcWPIKaziQ40uzjdyMeFBZsDRWGmAeq9KbBb2";
      openssh.authorizedKeys.keys = sshKeys;
    };
  };
}
