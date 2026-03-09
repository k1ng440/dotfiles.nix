{
  lib,
  machine,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  config = mkIf machine.windowManager.kde.enable {
    # Add KDE specific home-manager configuration here if needed
    # For now, we rely on Plasma 6 defaults and Stylix
  };
}
