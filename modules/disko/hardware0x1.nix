{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "NIXBOOT";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };

            swap = {
              label = "NIXSWAP";
              size = "12G";
              content = {
                type = "swap";
                resumeDevice = false;
              };
            };

            root = {
              label = "NIXROOT";
              size = "100%";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/";
                mountOptions = [
                  "noatime"
                  "nodiratime"
                  "inode64"
                  "discard"
                ];
              };
            };
          };
        };
      };
    };
  };
}
