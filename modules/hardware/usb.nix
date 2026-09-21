{
  flake.modules.nixos.hardware_usb =
    { lib, ... }:
    {
      # Periodic dropouts on AMD Matisse xhci; autosuspend on the internal hub
      # the peripherals sit behind makes the re-enumeration stalls worse.
      # pcie_aspm=off stops the controller power-managing the link, which is
      # what makes a dropped device fail to re-enumerate until reboot.
      boot = {
        kernelParams = lib.mkAfter [
          "usbcore.autosuspend=-1"
          "pcie_aspm=off"
        ];
      };
    };
}
