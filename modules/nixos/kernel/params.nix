{
  # Kernel parameters for hardening, power behavior, boot visuals, and device quirks.

  boot.kernelParams = [
    # disable all mitigations for Spectre, Meltdown, etc.
    "mitigations=off"

    # NixOS produces many wakeups per second, which is bad for battery life.
    # This kernel parameter disables the timer tick on the last 4 cores
    "nohz_full=4-7"

    # make stack-based attacks on the kernel harder
    "randomize_kstack_offset=on"

    # Disable legacy vsyscalls; this can break very old binaries.
    "vsyscall=none"

    # reduce most of the exposure of a heap attack to a single cache
    "slab_nomerge"

    # Disable debugfs which exposes sensitive kernel data
    "debugfs=off"

    # Treat recoverable kernel oopses as panics.
    "oops=panic"

    # only allow signed modules
    # "module.sig_enforce=1"

    # Block kernel memory access, including administrator inspection.
    # "lockdown=confidentiality"

    # enable buddy allocator free poisoning
    "page_poison=on"

    # Improve direct-map cache use and reduce page allocation predictability.
    "page_alloc.shuffle=1"

    # for debugging kernel-level slab issues
    # "slub_debug=FZP"

    # disable sysrq keys. sysrq is seful for debugging, but also insecure
    "sysrq_always_enabled=0" # 0 | 1 # 0 means disabled

    # Avoid atime updates on the root filesystem.
    "rootflags=noatime"

    # linux security modules
    "lsm=landlock,lockdown,yama,integrity,apparmor,bpf,tomoyo,selinux"

    # prevent the kernel from blanking plymouth out of the fb
    # "fbcon=nodefer"

    # https://en.wikipedia.org/wiki/Kernel_page-table_isolation
    # auto means kernel will automatically decide the pti state
    "pti=auto" # on || off

    # disable the intel_idle (it stinks anyway) driver and use acpi_idle instead
    "idle=nomwait"

    # enable IOMMU for devices used in passthrough and provide better host performance
    "iommu=pt"

    # disable usb autosuspend
    "usbcore.autosuspend=-1"

    # swap: resume and restores original swap space
    "noresume"

    # allow systemd to set and save the backlight state
    "acpi_backlight=native"

    # prevent the kernel from blanking plymouth out of the fb
    "fbcon=nodefer"

    # disable boot logo
    # "logo.nologo"

    # disable the cursor in vt to get a black screen during intermissions
    "vt.global_cursor_default=0"
  ];
}
