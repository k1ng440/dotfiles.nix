{ lib, ... }:
{
  # use path relative to the root of the project
  relativeToRoot = lib.path.append ../.;

  scanPaths =
    path:
    builtins.map (f: (path + "/${f}")) (
      builtins.attrNames (
        lib.attrsets.filterAttrs (
          name: _type:
          let
            isDefaultNix = name == "default.nix";
            isHelper = lib.strings.hasSuffix "-helper.nix" name;
            shouldIgnore = isDefaultNix || isHelper;
          in
          (_type == "directory" && builtins.pathExists (path + "/${name}/default.nix")) # include directories with default.nix
          || (
            !shouldIgnore && (lib.strings.hasSuffix ".nix" name) # include .nix files
          )
        ) (builtins.readDir path)
      )
    );

  # Generate GNOME monitors.xml from the monitors list
  generateMonitorsXml =
    monitors:
    let
      # Helper to generate a single monitor entry
      mkMonitor = m: ''
        <logicalmonitor>
          <x>${toString m.x}</x>
          <y>${toString m.y}</y>
          <scale>${toString (m.scale or 1)}</scale>
          <primary>${if m.primary or false then "yes" else "no"}</primary>
          <monitor>
            <monitorspec>
              <connector>${m.name}</connector>
              <vendor>unknown</vendor>
              <product>unknown</product>
              <serial>unknown</serial>
            </monitorspec>
            <mode>
              <width>${toString m.width}</width>
              <height>${toString m.height}</height>
              <rate>${toString m.refresh_rate}</rate>
            </mode>
          </monitor>
        </logicalmonitor>
      '';
    in
    ''
      <monitors version="2">
        <configuration>
          ${builtins.concatStringsSep "\n" (
            map mkMonitor (builtins.filter (m: m.enabled or true) monitors)
          )}
        </configuration>
      </monitors>
    '';
}
