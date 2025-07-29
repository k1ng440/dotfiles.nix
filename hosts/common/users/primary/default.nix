{ inputs, pkgs, config, lib, ... }:
let
  pubKeys = let
    keysPath = ./keys;
  in
    if builtins.pathExists keysPath
    then lib.filesystem.listFilesRecursive keysPath
  else [];
in
  {
  programs.fish.enable = true;

  # Use mkMerge with proper evaluation deferral
  users = lib.mkMerge [
    {
      groups.${config.machine.username} = {};
      users.${config.machine.username} = {
        name = config.machine.username;
        group = config.machine.username;
        uid = config.machine.userUid;
        shell = pkgs.fish;
        openssh.authorizedKeys.keys =
          lib.lists.forEach pubKeys (key: builtins.readFile key);
      };
    }
  ];

  systemd.tmpfiles.rules = [
    "d /home/${config.machine.username}/.ssh 0750 ${config.machine.username} ${config.machine.username} -"
    "d /home/${config.machine.username}/.ssh/sockets 0750 ${config.machine.username} ${config.machine.username} -"
  ];

  # Home manager configuration - evaluated lazily
  home-manager = lib.mkIf
    (inputs ? "home-manager" &&
      !config.machine.computed.isMinimal &&
      builtins.pathExists (lib.custom.relativeToRoot "home/${config.machine.username}/${config.machine.hostname}.nix")
    )
    {
      backupFileExtension = "bk";
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit pkgs inputs; machine = config.machine; };
      users.${config.machine.username} = {
        imports = [
          (lib.custom.relativeToRoot "home/${config.machine.username}/${config.machine.hostname}.nix")
        ];
      };
    };
}
