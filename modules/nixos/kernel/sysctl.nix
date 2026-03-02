# Kernel — sysctl tuning for performance, stability, and hardening
#
# Tuned for a 4c/8t Ryzen with 6 GB RAM running ZFS/XFS on NVMe.
{lib, ...}: {
  boot.kernel.sysctl = {
    # ── Memory / Swap (tuned for zram) ────────────────────────────────
    # 180 = optimal for zram on kernel 6.x — compressing into zram is
    # far cheaper than disk I/O, so the kernel should prefer it heavily.
    "vm.swappiness" = lib.mkForce 180;

    # Keep VFS (dentry/inode) caches longer — reclaiming causes visible
    # latency spikes during Nix builds.
    "vm.vfs_cache_pressure" = lib.mkForce 50;

    # ── Dirty page writeback (tuned for 6 GB RAM) ─────────────────────
    # Background writeback at 16 MB, forced sync at 64 MB.
    "vm.dirty_bytes" = lib.mkForce 67108864; # 64 MiB
    "vm.dirty_background_bytes" = lib.mkForce 16777216; # 16 MiB
    "vm.dirty_writeback_centisecs" = lib.mkForce 1500;

    # zram is not disk — no readahead benefit from clustering
    "vm.page-cluster" = lib.mkForce 0;

    # ── Watermarks (proactive reclamation) ─────────────────────────────
    # Wider gaps give kswapd headroom before direct-reclaim stalls the UI.
    "vm.watermark_boost_factor" = lib.mkForce 15000;
    "vm.watermark_scale_factor" = lib.mkForce 200;

    # ── Kernel hardening ──────────────────────────────────────────────
    # Disable NMI watchdog — saves power, reduces interrupts
    "kernel.nmi_watchdog" = lib.mkForce 0;

    # ASLR maximum (2 = full randomization for mmap, stack, VDSO)
    "kernel.randomize_va_space" = lib.mkForce 2;

    # Allow unprivileged user namespaces (containers, sandboxes, browsers)
    "kernel.unprivileged_userns_clone" = lib.mkForce 1;

    # Quiet console — only critical messages
    "kernel.printk" = lib.mkForce "3 3 3 3";

    # Restrict kernel pointer leaks — prevents address disclosure
    "kernel.kptr_restrict" = lib.mkForce 2;

    # Restrict dmesg to root — prevents info leak
    "kernel.dmesg_restrict" = lib.mkForce 1;

    # Restrict perf event access — prevents hardware side-channel attacks
    "kernel.perf_event_paranoid" = lib.mkForce 3;

    # Disable core dumps for suid binaries
    "fs.suid_dumpable" = lib.mkForce 0;

    # Protect hardlinks/symlinks from ToCToU races
    "fs.protected_hardlinks" = lib.mkForce 1;
    "fs.protected_symlinks" = lib.mkForce 1;
    "fs.protected_fifos" = lib.mkForce 2;
    "fs.protected_regular" = lib.mkForce 2;

    # ── Network hardening ─────────────────────────────────────────────
    "net.core.netdev_max_backlog" = lib.mkForce 4096;
    "net.core.default_qdisc" = lib.mkForce "fq";
    "net.ipv4.tcp_congestion_control" = lib.mkForce "bbr";

    # # SYN flood protection
    # "net.ipv4.tcp_syncookies" = lib.mkForce 1;
    # "net.ipv4.tcp_max_syn_backlog" = lib.mkForce 4096;

    # # Disable ICMP redirects — prevents MITM routing attacks
    # "net.ipv4.conf.all.accept_redirects" = lib.mkForce 0;
    # "net.ipv4.conf.default.accept_redirects" = lib.mkForce 0;
    # "net.ipv4.conf.all.send_redirects" = lib.mkForce 0;
    # "net.ipv4.conf.default.send_redirects" = lib.mkForce 0;
    # "net.ipv6.conf.all.accept_redirects" = lib.mkForce 0;
    # "net.ipv6.conf.default.accept_redirects" = lib.mkForce 0;

    # # Disable source routing — prevents IP spoofing
    # "net.ipv4.conf.all.accept_source_route" = lib.mkForce 0;
    # "net.ipv4.conf.default.accept_source_route" = lib.mkForce 0;
    # "net.ipv6.conf.all.accept_source_route" = lib.mkForce 0;
    # "net.ipv6.conf.default.accept_source_route" = lib.mkForce 0;

    # # Log Martian packets — detect spoofed traffic
    # "net.ipv4.conf.all.log_martians" = lib.mkForce 1;
    # "net.ipv4.conf.default.log_martians" = lib.mkForce 1;

    # # Enable reverse-path filtering (strict mode)
    # "net.ipv4.conf.all.rp_filter" = lib.mkForce 1;
    # "net.ipv4.conf.default.rp_filter" = lib.mkForce 1;

    # IPv6 privacy extensions
    "net.ipv6.conf.all.use_tempaddr" = lib.mkForce 2;
    "net.ipv6.conf.default.use_tempaddr" = lib.mkForce 2;

    # ── Filesystem ────────────────────────────────────────────────────
    "fs.file-max" = lib.mkForce 2097152;
    # Raise inotify limits for IDEs (VS Code, IntelliJ, etc.)
    "fs.inotify.max_user_watches" = lib.mkForce 524288;
    "fs.inotify.max_user_instances" = lib.mkForce 1024;
  };
}
