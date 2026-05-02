{
  services = {
    # GVfs, a userspace virtual filesystem.
    gvfs.enable = true;

    # storage daemon required for udiskie auto-mount
    udisks2.enable = true;
  };
}
