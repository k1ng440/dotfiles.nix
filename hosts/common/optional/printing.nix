{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.brscan4
    (pkgs.xsane.override { gimpSupport = true; })
  ];

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };
    printing = {
      enable = true;
      listenAddresses = [ "localhost:631" "127.0.0.1:631" ];
      allowFrom = [ "all" ];
      browsing = true;
      defaultShared = true;
      openFirewall = true;
      startWhenNeeded = false;
    };
  };

  hardware = {
    sane = {
      enable = true;
      brscan4 = {
        enable = true;
        netDevices = {
          home = {
            model = "DCP-T510W";
            ip = "192.168.50.240";
          };
        };
      };
    };

    printers = {
      ensureDefaultPrinter = "Brother_DCP-T510W";
      ensurePrinters = [
        {
          deviceUri = "ipp://192.168.50.240/ipp";
          location = "home";
          name = "Brother_DCP-T510W";
          model = "everywhere";
          ppdOptions = {
            media = "iso_a4_210x297mm";
            OutputOrder = "Reverse";

            # IPP scaling options:
            print-scaling = "fit";
            print-quality = "normal";
            orientation-requested = "portrait";
          };
        }
      ];
    };
  };
}
