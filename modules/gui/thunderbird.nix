{
  flake.modules.nixos.programs_thunderbird =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.thunderbird-bin ];

      custom.persist = {
        home.directories = [ ".thunderbird" ];
      };
    };
}
