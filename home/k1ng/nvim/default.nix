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
    extraPackages = with pkgs; [
      lua-language-server
      nil
      tree-sitter
      bash-language-server
      stylua
      shfmt
      luajitPackages.jsregexp
      vscode-langservers-extracted
    ];
  };

  xdg.configFile."nvim".source = nvimConfigDirectory;
  xdg.configFile."intelephense/license.txt".source = intelephenseLicenseFile;
}
