{
  npins,
  pkgs,
  lib,
  config,
  inputs,
  machine,
  ...
}:
let
  nvimConfigDirectory = config.lib.file.mkOutOfStoreSymlink "${machine.home}/nix/nix-config/home/${machine.username}/nvim/config";
  intelephenseLicenseFile = config.lib.file.mkOutOfStoreSymlink "/home/k1ng/nix/nix-config/secrets/intelephense-license.txt";
  plugins = import ./plugins2.nix {
    inherit
      pkgs
      npins
      inputs
      lib
      ;
  };
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    inherit plugins;
    package =
      inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.neovim-unwrapped;
    extraPackages = [
      pkgs.tree-sitter
      pkgs.bash-language-server
      pkgs.stylua
      pkgs.shfmt
      pkgs.luajitPackages.jsregexp
    ];
  };

  xdg.configFile."nvim".source = nvimConfigDirectory;
  xdg.configFile."intelephense/license.txt".source = intelephenseLicenseFile;
}
