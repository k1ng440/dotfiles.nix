{ lib, ... }:
let
  templateType = lib.types.submodule {
    options = {
      # str or path: some callers pass a `pkgs.writeText` derivation rather than
      # a string, and the TOML generator coerces either to a store path.
      input_path = lib.mkOption {
        type = lib.types.oneOf [
          lib.types.str
          lib.types.path
        ];
        description = "Template file noctalia renders the active palette into.";
      };
      output_path = lib.mkOption {
        type = lib.types.oneOf [
          lib.types.str
          lib.types.path
        ];
        description = "Where the rendered template is written.";
      };
      post_hook = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.oneOf [
            lib.types.str
            lib.types.path
          ]
        );
        default = null;
        description = "Command run after rendering, with the template context available.";
      };
    };
  };
in
{
  flake.modules.nixos.core = _: {
    options.custom.programs.noctalia = {
      colors = lib.mkOption {
        type = lib.types.submodule {
          options = {
            templates = lib.mkOption {
              type = lib.types.attrsOf templateType;
              default = { };
              description = ''
                Per-app theme templates, keyed by an arbitrary name.

                These are merged into Noctalia's config as
                `[theme.templates.user.<name>]` entries, which is the same
                `input_path` / `output_path` / `post_hook` shape v4 expected,
                so declaring a template here keeps working unchanged.
              '';
            };
          };
        };
        default = { };
        description = "Colour-related Noctalia configuration.";
      };
    };
  };

  flake.modules.nixos.wm =
    { config, ... }:
    {
      # Fold the collected templates into `[theme.templates.user]`.
      # recursiveUpdate matters: `theme` already carries mode/source from the
      # base settings, and a plain `//` would replace the whole table.
      #
      # post_hook is nullOr with a null default, so drop nulls before rendering
      # TOML rather than emitting an empty key.
      custom.programs.noctalia.settingsReducers = [
        (
          prev:
          lib.recursiveUpdate prev {
            theme.templates.user = lib.mapAttrs (
              _name: template: lib.filterAttrs (_: value: value != null) template
            ) config.custom.programs.noctalia.colors.templates;
          }
        )
      ];
    };
}
