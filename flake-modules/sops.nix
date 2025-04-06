{sops-nix}: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit lib;
  flattenAttrs = prefix: attrs: (builtins.listToAttrs (lib.concatMap (key: let
    newPrefix =
      if prefix == ""
      then key
      else "${prefix}/${key}";
  in
    if builtins.isAttrs attrs.${key}
    then flattenAttrs newPrefix attrs.${key}
    else [
      {
        name = newPrefix;
        value = {mode = "0400";};
      }
    ]) (builtins.attrNames attrs)));

  # Read and parse YAML secrets only if they contain `sops:`
  parseYamlSecrets = file: (let
    yamlData = builtins.fromJSON (builtins.readFile file);
    filename = lib.removeSuffix ".yaml" (baseNameOf file);
  in
    if (lib.hasAttr "sops" yamlData)
    then flattenAttrs filename (lib.removeAttrs yamlData ["sops"])
    else {});

  # Read all secret YAML files, but only include valid SOPS-managed ones
  secretFiles = builtins.attrNames (builtins.readDir ../secrets);
  parsedSecrets = builtins.listToAttrs (lib.concatMap (file:
    if lib.hasSuffix ".yaml" file
    then let
      parsed = parseYamlSecrets ("../secrets/" + file);
    in
      builtins.trace "Parsed secrets from ${file}: ${toString parsed}"
      (lib.mapAttrs (_: v: v // {sopsFile = "../secrets/" + file;}) parsed)
    else [])
  secretFiles);
  # parsedSecrets = builtins.listToAttrs (
  #   lib.concatMap (
  #     file:
  #     if lib.hasSuffix ".yaml" file then
  #       let
  #         parsed = parseYamlSecrets ("../secrets/" + file);
  #       in
  #       lib.mapAttrs (_: v: v // { sopsFile = "../secrets/" + file; }) parsed
  #     else
  #       [ ]
  #   ) secretFiles
  # );
in {
  imports = [sops-nix.nixosModules.sops];

  options.sops-defaultSopFile = lib.mkOption {
    type = lib.types.attrsOf lib.types.string;
    default = ../secrets/secrets.yaml;
    description = "The default sops file used for all secrets can be controlled using `sops.defaultSopsFile`";
  };

  options.sops-secrets = lib.mkOption {
    type = lib.types.attrsOf lib.types.attrs;
    default = {};
    description = "A set of secrets managed by sops-nix";
  };

  config = {
    environment.systemPackages = with pkgs; [sops age];

    # https://dl.thalheim.io/
    sops = {
      validateSopsFiles = true;
      age = {
        keyFile = "/var/lib/sops-nix/keys.txt";
        generateKey = false;
      };
      defaultSopsFile = ../secrets/secrets.yaml;
      # Merge auto-parsed secrets with manually defined ones
      secrets = lib.mkMerge [parsedSecrets config.sops-secrets];
    };
  };
}
