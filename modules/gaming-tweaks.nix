_: {
  flake.modules.nixos.gaming_tweaks = _: {
    boot.kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_fastopen" = 3;
      "kernel.split_lock_mitigate" = 0;
      "kernel.nmi_watchdog" = 0;
      "vm.vfs_cache_pressure" = 50;
      "vm.swappiness" = 10;
      "vm.stat_interval" = 5;
    };

    services.irqbalance.enable = true;
  };
}
