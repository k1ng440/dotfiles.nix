{imports, pkgs, config, ...}: {
  imports = [
    imports.stylix.nixosModules.stylix
  ];

  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
}
