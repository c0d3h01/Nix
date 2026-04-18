{
  pkgs,
  hostConfig,
  ...
}: {
  # Identity & Time
  networking.hostName = hostConfig.hostname;
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
  system.stateVersion = hostConfig.stateVersion;

  # Shell Environment
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Primary User Configuration
  # users.groups.${hostConfig.username} = {};
  users.groups = {
    root = {};
    c0d3h01 = {};
    anon = {};
  };

  # User Configuration
  users.users.${hostConfig.username} = {
    isNormalUser = true;
    createHome = true;
    description = hostConfig.fullName;
    group = hostConfig.username;
    shell = pkgs.zsh;

    extraGroups = [
      "wheel" # Admin privileges via sudo.
      "adm" # Read system logs (/var/log, journalctl).
      "cdrom" # Access optical drives (/dev/sr0).
      "dip" # Dial-up / PPP networking.
      "plugdev" # Access removable devices via udev.
      "users" # Default group for normal users.
      "lpadmin" # Manage printers via CUPS
    ];
  };
}
