{ lib, ... }:
{
  relativeToRoot = lib.path.append ../.;

  scanPaths =
    path:
    let
      scanDir =
        dir:
        builtins.attrNames (
          lib.attrsets.filterAttrs (
            name: _type:
            let
              isDefaultNix = name == "default.nix";
              isHelper = lib.strings.hasSuffix "-helper.nix" name;
              shouldIgnore = isDefaultNix || isHelper;
            in
            (_type == "directory" && builtins.pathExists (dir + "/${name}/default.nix"))
            || (!shouldIgnore && (lib.strings.hasSuffix ".nix" name))
          ) (builtins.readDir dir)
        );
    in
    builtins.map (f: (path + "/${f}")) (lib.lists.remove "user" (scanDir path));

  # Safely extract secrets from optional flake inputs.
  # It handles missing inputs, dot-notated attribute paths (e.g., "ssh.matchBlocks"),
  # and automatically evaluates any functions found by passing 'lib' to them.
  getSecret =
    inputs: inputName: path: default:
    let
      input = inputs.${inputName} or null;
      attrPath = if builtins.isString path then lib.splitString "." path else path;
      # Safely walk the attribute path
      raw = if input != null then lib.attrByPath attrPath null input else null;
      # Evaluate if it's a function (idiomatic for lib injection in this config)
      value = if builtins.isFunction raw then raw lib else raw;
    in
    if input == null then
      lib.warn "Input '${inputName}' is missing. Secret '${path}' cannot be loaded." default
    else if value == null then
      lib.warn "Secret path '${path}' not found in input '${inputName}'." default
    else
      value;
}
