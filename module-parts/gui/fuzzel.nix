{
  flake.modules.nixos.programs_zoom =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.fuzzel ];

      hj.xdg.config.files."fuzzel/fuzzel.ini" = {
        text = ''
          [border]
          radius=10
          width=2

          [colors]
          background=232136E6
          border=c4a7e7ff
          counter=e0def4ff
          input=e0def4ff
          match=ea9a97ff
          placeholder=6e6a86ff
          prompt=e0def4ff
          selection=393552ff
          selection-match=ea9a97ff
          selection-text=e0def4ff
          text=e0def4ff

          [main]
          fields=name,generic,comment,categories,filename,keywords
          font=Roboto:size=10
          horizontal-pad=20
          inner-pad=5
          line-height=25
          lines=5
          prompt='🌐 '
          terminal=kitty
          vertical-pad=10
          width=60
        '';
      };
    };
}
