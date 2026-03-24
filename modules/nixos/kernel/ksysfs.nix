{
  boot.kernel.sysfs = {
    kernel.mm.transparent_hugepage = {
      enabled = "madvise";

      # defer+madvise: async compaction only when process explicitly requests it
      defrag = "defer+madvise";

      shmem_enabled = "within_size";
    };
  };
}
