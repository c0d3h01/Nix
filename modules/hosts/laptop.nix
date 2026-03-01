let
  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICSjL8HGjiSAnLHupMZin095bql7A8+UDfc7t9XCZs8l c0d3h01"
  ];
in {
  imports = [
    ../disko/hardware0x0.nix
  ];

  users.users = {
    root.openssh.authorizedKeys.keys = sshKeys;

    c0d3h01 = {
      home = "/home/c0d3h01";
      hashedPassword = "$y$j9T$jbMpDi1jashn36Vczb8jO/$E8M0edjvWOZg24Su5bFWaQ5tHcPkwyQ8HdzkAMx0km7";
      openssh.authorizedKeys.keys = sshKeys;
    };
  };
}
