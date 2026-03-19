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
}
