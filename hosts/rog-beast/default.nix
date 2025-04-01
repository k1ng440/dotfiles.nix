{ }:
{
  info = (import ./info.nix) { };
  nixosModules = ./os.nix;
  homeModules = ./home.nix;
}
