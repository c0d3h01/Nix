{
  config,
  lib,
  pkgs,
  ...
}: let
  userName = "anon";
  secretName = "ssh_auth_keys_${userName}";
in {
  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    allowSFTP = true;
    openFirewall = true;
    ports = [22];

    # Read user keys from the home directory and the SOPS-rendered path.
    settings.AuthorizedKeysFile = "%h/.ssh/authorized_keys /run/secrets-for-users/%N/${userName}";

    # Host keys.
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
      # Authentication and exposure.
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AuthenticationMethods = "publickey";
      UsePAM = false;
      UseDns = false;
      X11Forwarding = false;

      # Keepalive behavior.
      ClientAliveInterval = 60;
      ClientAliveCountMax = 5;

      # Modern key exchange, cipher, and MAC allowlists.
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

  # SOPS-rendered authorized_keys for this user.
  sops.secrets.${secretName} = {
    owner = "root";
    group = "root";
    mode = "0400";

    # Must match AuthorizedKeysFile; %N scopes secrets by host.
    path = "/run/secrets-for-users/%N/${userName}";
  };
}
