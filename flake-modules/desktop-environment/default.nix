/*
*
Flake-module entry point for Desktop Environment.

It provides outputs for:

- Checks for automatic tests
- home-manager(?) module for installing the environment
*/
{ withSystem, self, ... }: {
  flake = {
    nixosModules.de = import ./nixosModules {};
    homeManagerModules.de = import ./homeManagerModules {};
  };
}

