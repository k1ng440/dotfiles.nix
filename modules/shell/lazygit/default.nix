{
  flake.modules.nixos.shell_lazygit =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.lazygit
        pkgs.commitizen
      ];
      hj.xdg.config.files."lazygit/config.yml".text = builtins.readFile ./config.yml;
    };
}
