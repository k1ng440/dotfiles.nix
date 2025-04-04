{
  config,
  lib,
  ...
}: let
  inherit (lib) mkDefault;
in {
  boot = {
    # tmpfs = /tmp is mounted in ram. Doing so makes temp file management speedy
    # on ssd systems, and volatile! Because it's wiped on reboot.
    tmpOnTmpfs = mkDefault true;

    # If not using tmpfs, which is naturally purged on reboot, we must clean it
    # /tmp ourselves. /tmp should be volatile storage!
    cleanTmpDir = mkDefault (!config.boot.tmpOnTmpfs);
  };
}
