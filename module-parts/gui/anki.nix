{
  flake.modules.nixos.programs_anki =
    { lib, pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.anki-bin ];

      custom.persist = {
        home.directories = [ ".local/share/Anki2" ];
      };
      custom.programs.which-key.menus = {
        a = {
          desc = "Anki";
          cmd = lib.getExe pkgs.anki-bin;
        };
      };
    };
}
