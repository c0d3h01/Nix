{
  boot.kernel.sysctl = {
    # Aggressively use ZRAM before hitting OOM
    "vm.swappiness" = 180;

    # Allow ZRAM to fill up completely before killing processes
    "vm.watermark_scale_factor" = 200;

    # Keep file caches smaller to prioritize app memory
    "vm.vfs_cache_pressure" = 100;

    # Reduce disk I/O latency spikes (dirty pages)
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;

    # Disable Transparent Hugepages to prevent latency spikes (critical for low-latency)
    "vm.transparent_hugepage" = "madvise";
    "vm.compact_unevictable_allowed" = 0;
  };
}
