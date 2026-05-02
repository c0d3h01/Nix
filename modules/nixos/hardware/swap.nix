{
  # Enable zswap as a compressed in-RAM cache for swap pages.

  boot.kernelParams = [
    "zswap.enabled=1" # enables zswap
    "zswap.compressor=lz4" # compression algorithm
    "zswap.max_pool_percent=20" # maximum percentage of RAM that zswap is allowed to use
    "zswap.shrinker_enabled=1" # whether to shrink the pool proactively on high memory pressure
    "zswap.zpool=zsmalloc" # allocator for compressed pages
  ];

  # Load lz4 compression modules.
  boot.initrd.kernelModules = [
    "lz4"
    "lz4_compress"
  ];

  # ----
  # Optional zram swap device for more compressed RAM-backed swap.

  # zramSwap = {
  #   enable = true;
  #   priority = 100;
  #   algorithm = "zstd";
  #   memoryPercent = 100;
  # };
}
