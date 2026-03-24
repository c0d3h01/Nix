{
  # https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html
  boot.kernelParams = [
    # disable all mitigations for Spectre, Meltdown, etc.
    "mitigations=off"

    #
    "quiet"
    "splash"

    # make stack-based attacks on the kernel harder
    "randomize_kstack_offset=on"

    # controls the behavior of vsyscalls. this has been defaulted to none back in 2016 - break really old binaries for security
    "vsyscall=none"

    # reduce most of the exposure of a heap attack to a single cache
    "slab_nomerge"

    # Disable debugfs which exposes sensitive kernel data
    "debugfs=off"

    # Sometimes certain kernel exploits will cause what is called an "oops" which is a kernel panic
    # that is recoverable. This will make it unrecoverable, and therefore safe to those attacks
    "oops=panic"

    # only allow signed modules
    "module.sig_enforce=1"

    # integrity: protects kernel image + /dev/mem without breaking amdgpu firmware
    # confidentiality breaks Vega 8 firmware loading path and suspend/resume
    "lockdown=integrity"

    # enable buddy allocator free poisoning
    "page_poison=on"

    # performance improvement for direct-mapped memory-side-cache utilization, reduces the predictability of page allocations
    "page_alloc.shuffle=1"

    # disable sysrq keys. sysrq is seful for debugging, but also insecure
    "sysrq_always_enabled=0"

    # ignore access time (atime) updates on files, except when they coincide with updates to the ctime or mtime
    "rootflags=noatime"

    # linux security modules
    "lsm=landlock,lockdown,yama,integrity,apparmor,bpf,tomoyo,selinux"

    # prevent the kernel from blanking plymouth out of the fb
    "fbcon=nodefer"
  ];
}
