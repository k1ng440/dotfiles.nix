# User config applicable only to nixos
{
  config,
  lib,
  pkgs,
  ...
}:
let
  machineDefined = config ? "machine" && config.machine ? "username";
in
{
  users = lib.mkIf machineDefined {
    groups.${config.machine.username} = {
      gid = config.machine.userUid;
    };

    mutableUsers = false;
    users."${config.machine.username}" = {
      home = "/home/${config.machine.username}";
      uid = config.machine.userUid;
      isNormalUser = true;
      hashedPasswordFile = lib.optionalString (
        !config.machine.computed.isMinimal
      ) config.sops.secrets."passwords/${config.machine.username}".path;
      group = config.machine.username;
      createHome = true;

      extraGroups = lib.flatten [
        "wheel"
        (builtins.filter (group: builtins.hasAttr group config.users.groups) [
          "audio"
          "video"
          "docker"
          "git"
          "networkmanager"
          "scanner"
          "lp"
          "adbusers"
          "kvm"
          "libvirtd"
          "seat"
          "pcscd"
        ])
      ];
    };

    users.root = {
      shell = pkgs.bash;
      inherit (config.users.users.${config.machine.username}) hashedPasswordFile;
      inherit (config.users.users.${config.machine.username}) hashedPassword;
      openssh.authorizedKeys.keys =
        config.users.users.${config.machine.username}.openssh.authorizedKeys.keys;
    };
  };
}
