{
  config,
  lib,
  pkgs,
  ...
}: let
  userName = "c0d3h01";
  secretName = "ssh_auth_keys_${userName}";
in {
  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    allowSFTP = true;
    openFirewall = true;
    ports = [22];

    # Tell SSH to look in the sops-decrypted location for user keys
    settings.AuthorizedKeysFile = "%h/.ssh/authorized_keys /run/secrets-for-users/%N/${userName}";

    # Host Keys: Ed25519, RSA
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];

    settings = {
      # Security Hardening
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AuthenticationMethods = "publickey";
      UsePAM = false;
      UseDns = false;
      X11Forwarding = false;

      # Stability
      ClientAliveInterval = 60;
      ClientAliveCountMax = 5;

      # Cryptography
      KexAlgorithms = [
        "mlkem768x25519-sha256"
        "sntrup761x25519-sha512@openssh.com"
        "curve25519-sha256"
        "curve25519-sha256@libssh.org"
        "diffie-hellman-group16-sha512"
        "diffie-hellman-group18-sha512"
        "diffie-hellman-group-exchange-sha256"
      ];
      Ciphers = [
        "chacha20-poly1305@openssh.com"
        "aes256-gcm@openssh.com"
        "aes128-gcm@openssh.com"
      ];
      Macs = [
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
        "umac-128-etm@openssh.com"
      ];
    };
  };

  # SOPS Integration for SSH Keys
  sops.secrets.${secretName} = {
    # Owner/Group usually root, but SSH reads it as the user logic handles permissions
    owner = "root";
    group = "root";
    mode = "0400";

    # This path must match the 'AuthorizedKeysFile' entry above
    # %N expands to the node name (hostname), ensuring isolation if you share secrets
    path = "/run/secrets-for-users/%N/${userName}";
  };
}
