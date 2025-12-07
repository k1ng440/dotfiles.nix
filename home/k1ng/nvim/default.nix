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
      pkgs.bash-language-server
      pkgs.shfmt
      pkgs.goimports-reviser
      pkgs.golines
      pkgs.gopls
      pkgs.gosimports
      pkgs.htmx-lsp
      pkgs.lua-language-server
      pkgs.luaformatter
      pkgs.nixfmt-rfc-style
      pkgs.docker-compose-language-service
      pkgs.nodePackages.dockerfile-language-server-nodejs
      pkgs.nodePackages.typescript-language-server
      pkgs.nodePackages.vscode-langservers-extracted
      pkgs.nodePackages."@vue/language-server"
      pkgs.basedpyright
      pkgs.prettierd
      pkgs.pyright
      pkgs.rust-analyzer
      pkgs.rustfmt
      pkgs.svelte-language-server
      pkgs.tailwindcss-language-server
      pkgs.templ
      pkgs.terraform-ls
      pkgs.vim-language-server
      pkgs.yaml-language-server
      pkgs.python312Packages.mdformat
      pkgs.jdt-language-server
      pkgs.stylua
      pkgs.dockerfile-language-server-nodejs
      pkgs.nil
      pkgs.yamlfmt
      pkgs.chafa
      pkgs.fswatch
      pkgs.tree-sitter
      pkgs.pyright
      pkgs.xmlformat
      pkgs.nixd
    ];
  };

  xdg.configFile."nvim".source = nvimConfigDirectory;
  xdg.configFile."intelephense/license.txt".source = intelephenseLicenseFile;
}
