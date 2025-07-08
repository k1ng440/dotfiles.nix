{
  pkgs,
  system,
  inputs,
  ...
}:
{
  systemPackages = with pkgs; [
    inputs.nixos-needtoreboot.packages.${system}.default
  ];

  system = {
    activationScripts.diff = {
      supportsDryActivation = true;
      text = ''
        if [ -e /run/current-system/boot.json ] && ! ${pkgs.gnugrep}/bin/grep -q "LABEL=nixos-minimal" /run/current-system/boot.json; then
        ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
        fi
        /run/current-system/sw/bin/nixos-reedsreboot
      '';
    };
  };
}
