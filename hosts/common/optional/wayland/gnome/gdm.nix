{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (config.machine) username;
  # gdmConfigDir = "/var/lib/gdm3/.config";
  gdmConfigDir = "/var/lib/gdm/seat0/config";

  monitorsXmlContent =
    if config.machine.desktop.monitorsXml != null then
      config.machine.desktop.monitorsXml
    else if config.monitors != [ ] then
      lib.custom.generateMonitorsXml config.monitors
    else
      null;
in
{
  config = lib.mkIf config.machine.windowManager.gnome.enable {
    systemd = {
      tmpfiles.rules = lib.mkIf (monitorsXmlContent != null) [
        "d ${gdmConfigDir} 0711 gdm gdm -"
        "f ${gdmConfigDir}/monitors.xml 0644 gdm gdm - ${pkgs.writeText "gdm-monitors.xml" monitorsXmlContent}"
      ];

      services.applyUserMonitorSettings = lib.mkIf (monitorsXmlContent == null) {
        description = "Apply user monitor settings to GDM login screen";
        after = [
          "network.target"
          "systemd-user-sessions.service"
          "display-manager.service"
        ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "apply-gdm-monitors" ''
            if [ -f /home/${username}/.config/monitors.xml ]; then
              echo "Applying user monitor settings to GDM login screen"
              mkdir -p ${gdmConfigDir}
              cp /home/${username}/.config/monitors.xml ${gdmConfigDir}/monitors.xml
              chown gdm:gdm ${gdmConfigDir}/monitors.xml
              chmod 644 ${gdmConfigDir}/monitors.xml
            else
              echo "No monitor settings found for ${username}"
            fi
          '';
        };
      };

      services.user-icon = {
        before = [ "display-manager.service" ];
        wantedBy = [ "display-manager.service" ];

        serviceConfig = {
          Type = "simple";
          User = "root";
          Group = "root";
        };

        script = ''
          config_file=/var/lib/AccountsService/users/${username}
          icon_file=${lib.custom.relativeToRoot "home/common/wayland/common/face.jpg"}

          if ! [ -d "$(dirname "$config_file")" ]; then
            mkdir -p "$(dirname "$config_file")"
          fi

          if ! [ -f "$config_file" ]; then
            echo "[User]
            Session=gnome
            SystemAccount=false
            Icon=$icon_file" > "$config_file"
          else
            icon_config=$(sed -E -n -e "/Icon=.*/p" $config_file)

            if [[ "$icon_config" == "" ]]; then
              echo "Icon=$icon_file" >> $config_file
            else
              sed -E -i -e "s#^Icon=.*$#Icon=$icon_file#" $config_file
            fi
          fi
        '';
      };
    };
  };
}
