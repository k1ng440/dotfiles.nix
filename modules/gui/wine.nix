_: {
  flake.modules.nixos.programs_wine =
    {
      pkgs,
      lib,
      ...
    }:
    let
      bridge = pkgs.pkgsCross.mingw32.wine-discord-ipc-bridge;
    in
    {
      environment.systemPackages = with pkgs; [
        bottles
        lutris
        wineWow64Packages.waylandFull # wine 32+64, wayland, mono, gecko
        winetricks
        cabextract
        p7zip
        unzip
        wget
        corefonts
        dxvk
        vkd3d-proton
        pkgsi686Linux.vulkan-loader # 32-bit vulkan for dxvk
      ];

      systemd.user.services.wine-setup = {
        description = "Setup default Wine prefix (vcrun2019 + discord bridge)";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = lib.getExe (
            pkgs.writeShellApplication {
              name = "wine-setup";
              runtimeInputs = [
                pkgs.winetricks
                pkgs.wineWow64Packages.waylandFull
              ];
              text = ''
                marker="$HOME/.wine/.setup-done"
                [[ -f "$marker" ]] && exit 0

                winetricks -q vcrun2019 corefonts

                dest="$HOME/.wine/drive_c/windows/system32/winediscordipcbridge.exe"
                cp "${bridge}/bin/winediscordipcbridge.exe" "$dest"

                touch "$marker"
              '';
            }
          );
        };
      };

      systemd.user.services.wine-discord-bridge = {
        description = "Wine Discord IPC bridge";
        wantedBy = [ "graphical-session.target" ];
        after = [
          "graphical-session.target"
          "wine-setup.service"
        ];
        requires = [ "wine-setup.service" ];
        serviceConfig = {
          ExecStart = "${lib.getExe pkgs.wineWow64Packages.waylandFull} '$HOME/.wine/drive_c/windows/system32/winediscordipcbridge.exe'";
          Restart = "on-failure";
          RestartSec = 3;
        };
      };

      custom = {
        programs.which-key.menus = {
          W = {
            desc = "Bottles";
            cmd = lib.getExe pkgs.bottles;
          };
        };
        persist.home.directories = [
          ".local/share/applications"
          ".local/share/bottles"
          ".local/share/lutris"
          ".wine"
        ];
      };
    };
}
