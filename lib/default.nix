{ lib, ... }:
{
  # use path relative to the root of the project
  relativeToRoot = lib.path.append ../.;

  scanPaths =
    path:
    builtins.map (f: (path + "/${f}")) (
      builtins.attrNames (
        lib.attrsets.filterAttrs (
          name: _type:
          let
            isDefaultNix = name == "default.nix";
            isHelper = lib.strings.hasSuffix "-helper.nix" name;
            shouldIgnore = isDefaultNix || isHelper;
          in
          (_type == "directory" && builtins.pathExists (path + "/${name}/default.nix")) # include directories with default.nix
          || (
            !shouldIgnore && (lib.strings.hasSuffix ".nix" name) # include .nix files
          )
        ) (builtins.readDir path)
      )
    );
}
