{
  pkgs,
  lib,
  config,
  hostProfile,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkDefault optionals;
  cfg = config.dotfiles.nixos.system.nix-ld;
in {
  options.dotfiles.nixos.system.nix-ld.enable = mkEnableOption "nix-ld for running unpatched binaries";

  config = mkIf cfg.enable {
    programs.nix-ld.enable = mkDefault true;
    programs.nix-ld.libraries = with pkgs;
      [
        acl
        attr
        bzip2
        dbus
        expat
        fontconfig
        freetype
        fuse3
        icu
        libnotify
        libsodium
        libssh
        libunwind
        libusb1
        libuuid
        nspr
        nss
        stdenv.cc.cc
        util-linux
        zlib
        zstd
      ]
      ++ optionals config.hardware.graphics.enable [
        pipewire
        cups
        libxkbcommon
        pango
        mesa
        libdrm
        libglvnd
        libpulseaudio
        atk
        cairo
        alsa-lib
        at-spi2-atk
        at-spi2-core
        gdk-pixbuf
        glib
        gtk3
        libGL
        libappindicator-gtk3
        vulkan-loader
        libx11
        libxscrnsaver
        libxcomposite
        libxcursor
        libxdamage
        libxext
        libxfixes
        libxi
        libxrandr
        libxrender
        libxtst
        libxcb
        libxkbfile
        libxshmfence
      ];

    programs.appimage = {
      enable = hostProfile.isWorkstation;
      binfmt = true;
    };

    services.flatpak.enable = mkIf hostProfile.isWorkstation false;
  };
}
