{
  services.openssh = {
    enable = true;
    startWhenNeeded = true;

    allowSFTP = true;
    openFirewall = true;
    ports = [22];

    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AuthenticationMethods = "publickey";
      PubkeyAuthentication = "yes";
      ChallengeResponseAuthentication = "no";
      UsePAM = true;
      UseDns = false;
      X11Forwarding = false;

      LoginGraceTime = 30;
      MaxAuthTries = 3;
      MaxSessions = 5;
      MaxStartups = "3:50:10";

      KexAlgorithms = [
        "sntrup761x25519-sha512@openssh.com"
        "mlkem768x25519-sha256"
        "sntrup761x25519-sha512"
        "curve25519-sha256"
        "curve25519-sha256@libssh.org"
        "diffie-hellman-group16-sha512"
        "diffie-hellman-group18-sha512"
        "diffie-hellman-group-exchange-sha256"
      ];

      Macs = [
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
        "umac-128-etm@openssh.com"
      ];

      ClientAliveCountMax = 5;
      ClientAliveInterval = 60;
    };

    hostKeys = [
      {
        bits = 4096;
        path = "/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
      }
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
}
