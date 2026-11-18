_: {
  flake.modules.nixos.core = _: {
    # Execute shebangs that assume hardcoded shell paths
    services.envfs.enable = true;

    # Work around systemd "Refusing to run in unsupported environment where /usr/ is not populated."
    # error with tmpfs:
    # https://github.com/Mic92/envfs/issues/203
    boot.initrd.systemd.tmpfiles.settings = {
      "50-usr-bin" = {
        "/sysroot/usr/bin" = {
          d = {
            group = "root";
            mode = "0755";
            user = "root";
          };
        };
      };
    };

    fileSystems = {
      "/usr/bin".options = [
        "x-systemd.requires=modprobe@fuse.service"
        "x-systemd.after=modprobe@fuse.service"
      ];

      "/bin".enable = false;
    };
  };
}
