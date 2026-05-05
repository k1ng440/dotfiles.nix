{
  inputs,
  lib,
  self,
  ...
}:
let
  btopOptions = {
    cudaSupport = lib.mkEnableOption {
      description = "Enable nvidia support for btop";
    };

    rocmSupport = lib.mkEnableOption {
      description = "Enable radeon support for btop";
    };

    extraSettings = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.bool
          lib.types.float
          lib.types.int
          lib.types.str
        ]
      );
      default = { };
      example = {
        color_theme = "Default";
        theme_background = false;
      };
      description = ''
        Options to add to {file}`btop.conf` file.
        See <https://github.com/aristocratos/btop#configurability>
        for options.
      '';
    };
  };
  toBtopConf = lib.generators.toKeyValue {
    mkKeyValue = lib.generators.mkKeyValueDefault {
      mkValueString =
        v:
        if lib.isBool v then
          (if v then "True" else "False")
        else if lib.isString v then
          ''"${v}"''
        else
          toString v;
    } " = ";
  };
  baseBtopConf = {
    color_theme = "TTY";
    theme_background = false;
    cpu_single_graph = true;
    show_gpu_info = "Off";
    show_disks = true;
    show_swap = true;
    swap_disk = false;
    use_fstab = false;
    only_physical = false;
    zfs_arc_cached = true;
    shown_boxes = "cpu mem net proc gpu0";
    gpu_mirror_graph = false;
  };
in
{
  flake.wrapperModules.btop = inputs.wrappers.lib.wrapModule (
    {
      config,
      wlib,
      pkgs,
      ...
    }:
    {
      imports = [ wlib.modules.default ];

      options = btopOptions;

      config.package = lib.mkDefault (
        pkgs.btop.override {
          inherit (config) cudaSupport;
          inherit (config) rocmSupport;
        }
      );

      config.flags = {
        "--config" = config.constructFiles.generatedConfig.path;
      };

      config.constructFiles.generatedConfig = {
        content = toBtopConf (baseBtopConf // config.extraSettings);
        relPath = "btop.conf";
      };
      config.passthru.configPath = config.constructFiles.generatedConfig.outPath;
    }
  );

  perSystem =
    { pkgs, ... }:
    {
      packages.btop = (self.wrapperModules.btop.apply { inherit pkgs; }).wrapper;
    };

  flake.modules.nixos.core =
    { config, pkgs, ... }:
    let
      inherit (config.custom.constants) host;
    in
    {
      options.custom = {
        programs.btop = btopOptions // {
          disks = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "List of disks to monitor in btop";
          };
        };
      };

      config = {
        nixpkgs.overlays = [
          (_: prev: {
            btop =
              (self.wrapperModules.btop.apply {
                pkgs = prev;
                rocmSupport = host == "desktop" || host == "framework";
                extraSettings = {
                  color_theme = "noctalia";
                  disks_filter = lib.concatStringsSep " " (
                    [
                      "/"
                      "/boot"
                      "/persist"
                    ]
                    ++ config.custom.programs.btop.disks
                  );
                }
                // config.custom.programs.btop.extraSettings;
              }).wrapper;
          })
        ];

        environment.systemPackages = [
          pkgs.btop
        ];

        custom.programs.print-config = {
          btop = /* sh */ ''moor --lang ini "${pkgs.btop.passthru.configuration.constructFiles.generatedConfig}"'';
        };
      };
    };
}
