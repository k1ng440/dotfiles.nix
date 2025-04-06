{...}: {
  fileSystems."/" = {
    device = "zroot/root";
    fsType = "zfs";
  };
}
