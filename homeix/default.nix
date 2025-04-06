# The importApply argument. Use this to reference things defined locally,
# as opposed to the flake where this is imported.
localFlake:
# Regular module arguments; self, inputs, etc all reference the final user flake,
# where this module was imported.
{lib, ...}: {
  perSystem = {system, ...}: {
    #  flake.nixosModules.foo = localFlake.moduleWithSystem (
    #   perSystem@{ config }: localFlake.importApply ./nixosModules perSystem
    # );
    #
    # flake.homeManagerModules.foo = localFlake.moduleWithSystem (
    #   perSystem@{ config }: localFlake.importApply ./homeManagerModules perSystem
    # );
  };
}
