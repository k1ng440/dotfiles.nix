{ config, ... }:
{
  home.file = {
    ".face.icon".source = ./face.jpg;
    ".config/face.jpg".source = ./face.jpg;
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        immediate_render = true;
        grace = 0;
        hide_cursor = true;
      };
      animations = {
        enabled = true;
        bezier = "linear, 1, 1, 0, 0";
        animation = [
          "fadeIn, 1, 5, linear"
          "fadeOut, 1, 5, linear"
          "inputFieldDots, 1, 2, linear"
        ];
      };
      background = [
        {
          path = "${config.home.homeDirectory}/Pictures/Wallpapers/wallpapers/018.jpg";
          blur_passes = 2;
          blur_size = 4;
        }
      ];
      image = [
        {
          path = "${config.home.homeDirectory}/.config/face.jpg";
          size = 100;
          border_size = 0;
          border_color = "0xffdddddd";
          rounding = -1;
          reload_time = -1;
          position = "0, -293";
          halign = "center";
          valign = "center";
        }
      ];
      input-field = {
        monitor = "";
        size = "300, 30";
        outline_thickness = 0;
        dots_size = 0.25;
        dots_spacing = 0.55;
        dots_center = true;
        dots_rounding = -1;
        outer_color = "rgba(30, 30, 30, 0.7)";
        inner_color = "rgba(50, 50, 50, 0.5)";
        font_color = "rgba(200, 200, 200, 1.0)";
        fade_on_empty = false;
        placeholder_text = "";
        hide_input = false;
        check_color = "rgba(204, 136, 34, 0)";
        fail_color = "rgba(204, 34, 34, 0)";
        fail_text = "$FAIL <b>($ATTEMPTS)</b>";
        fail_transition = 300;
        capslock_color = -1;
        numlock_color = -1;
        bothlock_color = -1;
        invert_numlock = false;
        swap_font_color = false;
        position = "0, -468";
        halign = "center";
        valign = "center";
      };
      label = [
        {
          monitor = "";
          text = "cmd[update:1000] echo \"$(date +\"%A, %B %d\")\"";
          color = "rgba(242, 243, 244, 0.75)";
          font_size = 20;
          font_family = "Inter Bold";
          position = "0, 405";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "cmd[update:1000] echo \"$(date +\"%I:%M %p\")\"";
          color = "rgba(242, 243, 244, 0.75)";
          font_size = 93;
          font_family = "Inter Bold";
          position = "0, 310";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "Asaduzzaman Pavel";
          color = "rgba(242, 243, 244, 0.75)";
          font_size = 12;
          font_family = "Inter Bold";
          position = "0, -407";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "Enter Password";
          color = "rgba(242, 243, 244, 0.75)";
          font_size = 10;
          font_family = "Inter Bold";
          position = "0, -438";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
