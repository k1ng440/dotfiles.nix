{ pkgs, ... }:
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
        fcitx5-rose-pine
      ];

      settings = {
        inputMethod = {
          GroupOrder." 0" = "Default";
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "mozc";
          };
          "Groups/0/Items/0".Name = "keyboard-us";
          "Groups/0/Items/1".Name = "mozc";
        };

        globalOptions = {
          Behavior = {
            ActiveByDefault = false;
          };
          Hotkey = {
            EnumerateWithTriggerKeys = true;
            EnumerateSkipFirst = false;
            ModifierOnlyKeyTimeout = 250;
            TriggerInputMethod = "Control+Space";
          };
        };

        ui = {
          Theme = "rose-pine";
        };
      };
    };
  };
}
