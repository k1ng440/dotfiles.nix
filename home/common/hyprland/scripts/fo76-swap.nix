{ pkgs, config, ... }:

let
  hpkg = config.wayland.windowManager.hyprland.package;
  smart-tab = pkgs.writeShellScriptBin "fo76-smart-tab" ''
    ACTIVE_JSON=$(${hpkg}/bin/hyprctl activewindow -j)
    ACTIVE_CLASS=$(echo "$ACTIVE_JSON" | ${pkgs.jq}/bin/jq -r '.class')
    ACTIVE_ADDR=$(echo "$ACTIVE_JSON" | ${pkgs.jq}/bin/jq -r '.address')

    if [ "$ACTIVE_CLASS" = "steam_app_1151340" ]; then
        TARGET_ADDR=$(${hpkg}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -r ".[] | select(.class == \"steam_app_1151340\" and .address != \"$ACTIVE_ADDR\") | .address" | head -n 1)

        if [ -n "$TARGET_ADDR" ]; then
            ${hpkg}/bin/hyprctl dispatch focuswindow address:"$TARGET_ADDR"
            exit 0
        fi
    fi

    ${hpkg}/bin/hyprctl dispatch workspace previous
  '';
in
{
  home.packages = [
    smart-tab
    pkgs.jq
  ];

  wayland.windowManager.hyprland.settings = {
    bind = [
      "SUPER, Tab, exec, ${smart-tab}/bin/fo76-smart-tab"
    ];
  };
}
