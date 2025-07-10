{ ... }:
{
  boot = {
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot.enable = true;

    initrd.verbose = false;
    kernelParams = [
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];

    # Set the same sysctl settings as are set on SteamOS
    # kernel.sysctl = {
    #   # 20-shed.conf
    #   "kernel.sched_cfs_bandwidth_slice_us" = 3000;
    #   # 20-net-timeout.conf
    #   # This is required due to some games being unable to reuse their TCP ports
    #   # if they're killed and restarted quickly - the default timeout is too large.
    #   "net.ipv4.tcp_fin_timeout" = 5;
    #   # 30-splitlock.conf
    #   # Prevents intentional slowdowns in case games experience split locks
    #   # This is valid for kernels v6.0+
    #   "kernel.split_lock_mitigate" = 0;
    #   # 30-vm.conf
    #   # USE MAX_INT - MAPCOUNT_ELF_CORE_MARGIN.
    #   # see comment in include/linux/mm.h in the kernel tree.
    #   "vm.max_map_count" = 2147483642;
    # };

    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;
  };
}
