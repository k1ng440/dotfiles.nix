# User config applicable only to nixos
{
  config,
  lib,
  pkgs,
  ...
}:
let
  hostSpec = config.hostSpec;
  exisitngGroupOnly =
    groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;

  # Decrypt password to /run/secrets-for-users/ so it can be used to create the user
  sopsHashedPasswordFile = lib.optionalString (
    !config.hostSpec.isMinimal
  ) config.sops.secrets."passwords/${hostSpec.username}".path;
in
{
  users.groups.${hostSpec.username} = {
    gid = hostSpec.userUid;
  };

  users.mutableUsers = false; # Only allow declarative credentials; Required for password to be set via sops during system activation!
  users.users."${hostSpec.username}" = {
    home = "/home/${hostSpec.username}";
    uid = hostSpec.userUid;
    isNormalUser = true;
    hashedPasswordFile = sopsHashedPasswordFile; # Blank if sops is not working.
    group = hostSpec.username;
    createHome = true;

    extraGroups = lib.flatten [
      "wheel"
      (exisitngGroupOnly [
        "audio"
        "video"
        "docker"
        "git"
        "networkmanager"
        "scanner" # for print/scan"
        "lp" # for print/scan"
        "adbusers" # for Android
        "kvm"
        "libvirtd"
      ])
    ];
  };

  # root's ssh key are mainly used for remote deployment, borg, and some other specific ops
  users.users.root = {
    shell = pkgs.bash;
    hashedPasswordFile = config.users.users.${hostSpec.username}.hashedPasswordFile;
    hashedPassword = config.users.users.${hostSpec.username}.hashedPassword; # This comes from hosts/common/optional/minimal.nix and gets overridden if sops is working
    openssh.authorizedKeys.keys = config.users.users.${hostSpec.username}.openssh.authorizedKeys.keys; # root's ssh keys are mainly used for remote deployment.
  };
}
