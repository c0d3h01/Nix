{
  # Transparent hugepage defaults for mixed desktop workloads.

  boot.kernel.sysfs = {
    kernel.mm.transparent_hugepage = {
      enabled = "madvise";
      defrag = "defer";
      shmem_enabled = "within_size";
    };
  };
}
