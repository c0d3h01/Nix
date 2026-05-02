{
  # Disko layout for one GPT disk with an ESP and compressed Btrfs subvolumes.

  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            label = "nix-boot";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "fmask=0077"
                "dmask=0077"
              ];
            };
          };

          # plainSwap = {
          #   label = "nix-swap";
          #   size = "4G";
          #   content = {
          #     type = "swap";
          #     discardPolicy = "both";
          #     # resumeDevice = true;
          #   };
          # };

          # encryptedSwap = {
          #   label = "nix-swap";
          #   size = "4G";
          #   content = {
          #     type = "swap";
          #     randomEncryption = true;
          #     priority = 100;
          #   };
          # };

          root = {
            label = "nix-root";
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = ["-f"];
              subvolumes = {
                "/@" = {
                  mountpoint = "/";
                  mountOptions = [
                    "noatime"
                    "compress=zstd:3"
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
                    "compress=zstd:1"
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
