{ pkgs, ... }:
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        # font = "JetBrainsMono Nerd Font:size=12";
        width = 60;
        lines = 5;
        line-height = 25;
        horizontal-pad = 20;
        vertical-pad = 10;
        inner-pad = 5;
        fields = "name,generic,comment,categories,filename,keywords";
        terminal = "${pkgs.foot}/bin/foot";
        prompt = "'🌐 '";
      };
      # colors = {
      #   background = "1e1e2eff";
      #   text = "cdd6f4ff";
      #   match = "f38ba8ff";
      #   selection = "45475aff";
      #   selection-text = "cdd6f4ff";
      #   selection-match = "f38ba8ff";
      #   border = "b4befeff";
      # };
      border = {
        width = 2;
        radius = 10;
      };
    };
  };
}
