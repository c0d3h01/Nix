{
  mkHostOutputs = {
    hosts,
    users,
  }: let
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
  };
}
