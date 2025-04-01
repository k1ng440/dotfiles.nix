{ ... }:
let
  name = "rog-beast";
  diskPath = "/dev/sda";
  disko = import ./disko.nix { diskPath = diskPath; };
in
{
  name = name;
  diskPath = diskPath;
  disko = disko;
}
