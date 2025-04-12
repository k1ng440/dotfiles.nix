{ profile, ... }:
{
  # Services to start
  services = {
    libinput.enable = true; # Input Handling
    fstrim.enable = true; # SSD Optimizer
    gvfs.enable = true; # For Mounting USB & More
    openssh.enable = true; # Enable SSH
    blueman.enable = true; # Bluetooth Support
    tumbler.enable = true; # Image/video preview
    gnome.gnome-keyring.enable = true;

    # TODO: Only enable this on truested networks.
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    smartd = {
      enable = (profile != "vm");
      autodetect = true;
    };
  };
}
