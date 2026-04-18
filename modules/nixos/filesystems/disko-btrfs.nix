{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            label = "nixos-boot";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["fmask=0077" "dmask=0077"];
            };
          };

          # plainSwap = {
          #   label = "nixos-swap";
          #   size = "4G";
          #   content = {
          #     type = "swap";
          #     discardPolicy = "both";
          #     # resumeDevice = true;
          #   };
          # };

          encryptedSwap = {
            size = "4G";
            content = {
              type = "swap";
              randomEncryption = true;
              priority = 100;
            };
          };

          root = {
            label = "nixos-root";
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = ["-f"];
              subvolumes = {
                "/@" = {
                  mountpoint = "/";
                  mountOptions = [
                    "noatime"
                    "compress=zstd:1"
                  ];
                };

                "/@home" = {
                  mountpoint = "/home";
                  mountOptions = [
                    "noatime"
                    "compress=zstd:3"
                  ];
                };

                "/@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "noatime"
                    "compress=zstd:3"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
}
