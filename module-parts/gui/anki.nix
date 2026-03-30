{
  flake.modules.nixos.programs_anki =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.anki-bin ];

      custom.persist = {
        home.directories = [ ".local/share/Anki2" ];
      };
    };
}
