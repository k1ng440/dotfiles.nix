{
  config,
  inputs,
  isLima,
  isWorkstation,
  lib,
  outputs,
  pkgs,
  stateVersion,
  username,
  ...
}:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
  hasNvidiaGPU = lib.elem "nvidia" config.services.xserver.videoDrivers;
in {
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
    inputs.sops-nix.homeManagerModules.sops
    inputs.nix-index-database.hmModules.nix-index
    inputs.vscode-server.nixosModules.home

    ./nvim
    ./git.nix
    ./packages.nix
  ];

  catppuccin = {
    accent = "blue";
    flavor = "mocha";
    bat.enable = config.programs.bat.enable;
    bottom.enable = config.programs.bottom.enable;
    btop.enable = config.programs.btop.enable;
    cava.enable = config.programs.cava.enable;
    fish.enable = config.programs.fish.enable;
    fzf.enable = config.programs.fzf.enable;
    micro.enable = config.programs.micro.enable;
    starship.enable = config.programs.starship.enable;
    yazi.enable = config.programs.yazi.enable;
  };

  home = {
    inherit stateVersion;
    inherit username;
    homeDirectory =
      if isDarwin then
        "/Users/${username}"
      else
        "/home/${username}";
    file = {
    };
  };
}



  # flake.homeConfigurations = {
  #   k1ng = homeManagerConfiguration {
  #     pkgs = inputs.nixpkgs.legacyPackages.${system};
  #     extraSpecialArgs = {
  #       inherit system inputs;
  #     };
  #     modules = [
  #       self.homeManagerModules.de
  #       inputs.nix-index-database.hmModules.nix-index
  #       ./nvim
  #       ./git.nix
  #       ./packages.nix
  #       {
  #         useGlobalPkgs = true;
  #         useUserPackages = true;
  #         backupFileExtension = "backup";
  #
  #         home = {
  #           username = "k1ng";
  #           homeDirectory = "/home/k1ng";
  #           stateVersion = "24.11";
  #         };
  #       }
  #     ];
  #   });
  # };
