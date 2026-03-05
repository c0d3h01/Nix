{
  pkgs,
  userConfig,
  lib,
  ...
}: let
  isWorkstation = userConfig.workstation or false;

  coreTools = with pkgs; [
    curl
    wget
    httpie
    jq
    yq-go
    fd
    eza
    tree
    file
    unzip
    zip
    p7zip
    tldr
    gitFull
    git-lfs
    lazygit
    starship
    bat
    fzf
    ripgrep
    yt-dlp
  ];

  systemTools = with pkgs; [
    btop
    glances
    ncdu
    duf
    lsof
    pciutils
    usbutils
    dnsutils
    traceroute
    socat
    tcpdump
    nmap
  ];

  devTools = with pkgs; [
    clang
    cmake
    gnumake
    gdb
    strace
    ltrace
    pkg-config
    openssl.dev
    python3
    nodejs
    tokei
    hyperfine
    # GUI Tools
    (pkgs.wrapWithNixGL pkgs.wezterm "wezterm-gui")
    (pkgs.wrapWithNixGL pkgs.kitty "kitty")
  ];
in {
  home.packages =
    coreTools
    ++ systemTools
    ++ lib.optionals isWorkstation devTools;
}
