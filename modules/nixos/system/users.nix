{pkgs, ...}: {
  imports = [
    ../filesystems/btrfs.nix
  ];

  # Identity & Time
  networking.hostName = "nixos";
  time.timeZone = "Asia/Kolkata";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocales = ["en_IN/UTF-8"];
  i18n.extraLocaleSettings = {
    LC_CTYPE = "en_US.UTF-8";
    LC_MESSAGES = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_COLLATE = "en_US.UTF-8";
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # System State Version
  system.stateVersion = "25.11";

  # Shell Environment
  programs.zsh.enable = true;

  # User Configuration
  users.users = {
    root = {
      hashedPassword = "$y$j9T$KAIygNaHsr4EgJcn2Jto.1$9gK08qEPSw/Fll//2TCe5ijYIqavtnvoundIux8Uy5/";
    };

    c0d3h01 = {
      home = "/home/c0d3h01";
      isNormalUser = true;
      description = "Harshal Sawant";
      shell = pkgs.zsh;

      hashedPassword = "$y$j9T$jbMpDi1jashn36Vczb8jO/$E8M0edjvWOZg24Su5bFWaQ5tHcPkwyQ8HdzkAMx0km7";
      openssh.authorizedKeys.keys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICSjL8HGjiSAnLHupMZin095bql7A8+UDfc7t9XCZs8l";

      extraGroups = [
        "wheel"
        "users"
        "networkmanager"
      ];
    };

    anon = {
      home = "/home/anon";
      isNormalUser = true;
      description = "Anon";

      hashedPassword = "$y$j9T$IKXrH64o2Ni7mqraKV6ke/$3FtfHxmcWPIKaziQ40uzjdyMeFBZsDRWGmAeq9KbBb2";

      extraGroups = [
        "networkmanager"
      ];
    };
  };
}
