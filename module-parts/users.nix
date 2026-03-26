{ lib, inputs, ... }:
{
  flake.modules.nixos.core =
    { config, ... }:
    let
      inherit (config.custom.constants) user;
    in
    {
      options = {
        warnings = lib.mkOption {
          apply = lib.filter (
            w: !(lib.hasInfix "If multiple of these password options are set at the same time" w)
          );
        };
      };

      config = lib.mkMerge [
        {
          users = {
            mutableUsers = false;
            groups.${user} = { };

            users = {
              root = {
                initialPassword = "password";
                # hashedPasswordFile = "/persist/etc/shadow/root";
              };
              ${user} = {
                home = "/home/${user}";
                isNormalUser = true;
                group = user;
                initialPassword = "password";
                # hashedPasswordFile = "/persist/etc/shadow/${user}";
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
            };
          };
        }
        {
          sops.secrets = {
            "passwords/${user}" = {
              sopsFile = "${builtins.toString inputs.nix-secrets + "/sops"}/shared.yaml";
              neededForUsers = true;
            };
          };

          users.users = {
            root.hashedPasswordFile = lib.mkForce config.sops.secrets."passwords/${user}".path;
            ${user}.hashedPasswordFile = lib.mkForce config.sops.secrets."passwords/${user}".path;
          };
        }
      ];
    };
}
