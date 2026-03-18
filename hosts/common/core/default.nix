{
  lib,
  inputs,
  isNixOS,
  ...
}:
let
  platform = if isNixOS then "nixos" else "darwin";
in
{
  imports = lib.flatten [
    (map lib.custom.relativeToRoot [
      "hosts/common/core/${platform}.nix"
      "hosts/common/core/sops.nix"
      "hosts/common/core/ssh.nix"
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
}
