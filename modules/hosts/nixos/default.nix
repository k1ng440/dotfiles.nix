# Add your reusable NixOS modules to this directory, in their own file (https://wiki.nixos.org/wiki/NixOS_modules).
# They will automatically be imported below but must be enabled elsewhere in the config, such as in common/core,
# common/optional, or common/hosts files for example.
# These are modules you would share with others, not your personal configurations.

{ lib, ... }:
{
  imports = lib.custom.scanPaths ./.;
}
