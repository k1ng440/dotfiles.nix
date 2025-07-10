{
  inputs,
  lib,
  config,
  ...
}:
let
  sopsFolder = builtins.toString inputs.nix-secrets + "/sops";
in
{
  sops = {
    defaultSopsFile = "${sopsFolder}/${config.hostSpec.hostname}.yaml";
    validateSopsFiles = false;
    age = {
      # automatically import host SSH keys as age keys
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
  };

  sops.secrets = lib.mkMerge [
    {
      # These age keys are are unique for the user on each host and are generated on their own (i.e. they are not derived
      # from an ssh key).
      "keys/age" = {
        owner = config.users.users.${config.hostSpec.username}.name;
        inherit (config.users.users.${config.hostSpec.username}) group;
        # We need to ensure the entire directory structure is that of the user...
        path = "${config.hostSpec.home}/.config/sops/age/keys.txt";
      };
      # extract password/username to /run/secrets-for-users/ so it can be used to create the user
      "passwords/${config.hostSpec.username}" = {
        sopsFile = "${sopsFolder}/shared.yaml";
        neededForUsers = true;
      };
      "passwords/msmtp" = {
        sopsFile = "${sopsFolder}/shared.yaml";
      };
      "keys/u2f_keys" = {
        sopsFile = "${sopsFolder}/shared.yaml";
      };
    }
  ];

  # The containing folders are created as root and if this is the first ~/.config/ entry,
  # the ownership is busted and home-manager can't target because it can't write into .config...
  # FIXME(sops): We might not need this depending on how https://github.com/Mic92/sops-nix/issues/381 is fixed
  system.activationScripts.sopsSetAgeKeyOwnership =
    let
      ageFolder = "${config.hostSpec.home}/.config/sops/age";
      user = config.users.users.${config.hostSpec.username}.name;
      group = config.users.users.${config.hostSpec.username}.group;
    in
    ''
      mkdir -p ${ageFolder} && chown -R ${user}:${group} ${config.hostSpec.home}/.config
    '';

}
