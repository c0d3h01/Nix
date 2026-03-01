let
  users = {
    c0d3h01 = {
      fullName = "Harshal Sawant";
      workstation = true;
      windowManager = "gnome"; # Options = "gnome" | "kde" | "xfce"
    };

    lara = {
      fullName = "Lara";
      workstation = true;
      windowManager = "gnome"; # Options = "gnome" | "kde" | "xfce"
    };
  };

  hosts = {
    laptop = {
      arch = "x86_64";
      class = "nixos";
      path = ./c0d3h01.nix;

      primaryUser = "c0d3h01";
      users = [
        "c0d3h01"
        "lara"
      ];

      config = {
        hostname = "nixos";
        laptop.enable = true;
        system = "x86_64-linux";
        bootloader = "limine"; # Options = "systemd" | "limine" | "grub"
      };
    };
  };

  mkUserConfig = host: userName:
    host.config
    // users.${userName}
    // {
      username = userName;
    };

  mkHomeEntriesForHost = hostName: host: let
    mkUserEntry = userName: let
      userConfig = mkUserConfig host userName;
    in {
      name = "${userName}@${userConfig.hostname}";
      value = {
        inherit hostName userConfig;
      };
    };
  in
    [
      {
        name = hostName;
        value = {
          inherit hostName;
          userConfig = mkUserConfig host host.primaryUser;
        };
      }
    ]
    ++ builtins.map mkUserEntry host.users;

  mapAttrsToList = f: attrs:
    builtins.map (name: f name attrs.${name}) (builtins.attrNames attrs);
in {
  easyHosts =
    builtins.mapAttrs (_: host: {
      inherit (host) arch class path;
      specialArgs.userConfig = mkUserConfig host host.primaryUser;
    })
    hosts;

  home = builtins.listToAttrs (
    builtins.concatLists (
      mapAttrsToList mkHomeEntriesForHost hosts
    )
  );
}
