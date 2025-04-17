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
    };
    printing = {
      enable = true;
      # drivers = [
      #   pkgs.brgenml1lpr
      #   pkgs.brgenml1cupswrapper
      # ];
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
        }
      ];
    };
  };
}
