{
  lib,
  pkgs,
  inputs,
  isNixOS,
  config,
  ...
}:
let
  platform = if isNixOS then "nixos" else "darwin";
  platformModules = "${platform}Modules";
in
{
  imports = lib.flatten [
    inputs.catppuccin.${platformModules}.catppuccin
    inputs.sops-nix.${platformModules}.sops

    (map lib.custom.relativeToRoot [
      "modules/common"
      "modules/hosts/${platform}"

      "hosts/common/core/${platform}.nix"
      "hosts/common/core/sops.nix"
      "hosts/common/core/ssh.nix"
      "hosts/common/core/i18n.nix"
      "hosts/common/core/time.nix"

      "hosts/common/users/primary"
      "hosts/common/users/primary/${platform}.nix"
    ])
  ];

  # Core host spec
  machine =
    let
      hasSecrets = inputs ? nix-secrets;
    in
    {
      username = "k1ng";
      handle = "k1ng440";
      userFullName = "Asaduzzaman Pavel";
      msmtp = {
        enable = hasSecrets;
        config = if hasSecrets then inputs.nix-secrets.msmtp else { };
      };
      domain = if hasSecrets then (inputs.nix-secrets.domain or "workgroup") else "workgroup";
      email =
        if hasSecrets then (inputs.nix-secrets.email or "contact@iampavel.dev") else "contact@iampavel.dev";
      networking = { };
    };

  environment.systemPackages = [
    pkgs.just
    pkgs.openssh
    pkgs.findutils
  ];

  networking.hostName = config.machine.hostname;
}
