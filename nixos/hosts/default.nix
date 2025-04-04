{ lib, ... }:
let
  currentDir = ./.;
  isDirectoryAndNotTemplate = name: type: type == "directory" && (lib.strings.hasPrefix "_" name) == false && name != "template";
  directories = lib.filterAttrs isDirectoryAndNotTemplate (builtins.readDir currentDir);
  importDirectory = name: import (currentDir + "/${name}");
in
{
  imports = lib.mapAttrsToList (name: _: importDirectory name) directories;
}
