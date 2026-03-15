{
  pkgs,
  config,
  lib,
  ...
}:
let
  pubKeys =
    let
      keysPath = ./keys;
    in
    if builtins.pathExists keysPath then lib.filesystem.listFilesRecursive keysPath else [ ];

  exisitngGroupOnly =
    groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  programs.fish.enable = true;

  # Use mkMerge with proper evaluation deferral
  users = lib.mkMerge [
    {
      groups.${config.machine.username} = { };
      users.${config.machine.username} = {
        name = config.machine.username;
        group = config.machine.username;
        uid = config.machine.userUid;
        shell = pkgs.fish;
        openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
        extraGroups = lib.flatten [
          "wheel"
          (exisitngGroupOnly [
            "audio"
            "video"
            "render"
            "docker"
            "git"
            "networkmanager"
            "scanner" # for print/scan"
            "lp" # for print/scan"
            "adbusers" # for Android
            "kvm"
            "libvirtd"
            "seat"
            "pcscd"
            "lpadmin"
            "input"
            "wireshark"
            "gamemode"
          ])
        ];
      };

    }
  ];

  systemd.tmpfiles.rules = [
    "d /home/${config.machine.username}/.ssh 0750 ${config.machine.username} ${config.machine.username} -"
    "d /home/${config.machine.username}/.ssh/sockets 0750 ${config.machine.username} ${config.machine.username} -"
  ];
}
