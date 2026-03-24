{lib, ...}: {
  services.zram-generator = {
    enable = lib.mkDefault true;
    settings = {
      zram0 = {
        compression-algorithm = "lz4";
        fs-type = "swap";
        swap-priority = 100;
        zram-size = "ram";
      };
    };
  };
}
