{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (pkgs.stdenv) isLinux;
in
{
  programs.fish = {
    enable = true;
    shellAliases = {
      banner = lib.mkIf isLinux "${pkgs.figlet}/bin/figlet";
      banner-color = lib.mkIf isLinux "${pkgs.figlet}/bin/figlet $argv | ${pkgs.dotacat}/bin/dotacat";
      brg = "${pkgs.bat-extras.batgrep}/bin/batgrep";
      cat = "${pkgs.bat}/bin/bat --paging=never";
      clock = if isLinux then ''${pkgs.tty-clock}/bin/tty-clock -B -c -C 4 -f "%a, %d %b"'' else "";
      dmesg = "${pkgs.util-linux}/bin/dmesg --human --color=always";
      neofetch = "${pkgs.fastfetch}/bin/fastfetch";
      glow = "${pkgs.frogmouth}/bin/frogmouth";
      hr = ''${pkgs.hr}/bin/hr "─━"'';
      htop = "${pkgs.bottom}/bin/btm --basic --tree --hide_table_gap --dot_marker";
      ip = lib.mkIf isLinux "${pkgs.iproute2}/bin/ip --color --brief";
      less = "${pkgs.bat}/bin/bat";
      lm = "${pkgs.lima}/bin/limactl";
      lolcat = "${pkgs.dotacat}/bin/dotacat";
      lsusb = "${pkgs.cyme}/bin/cyme --headings";
      moon = "${pkgs.curlMinimal}/bin/curl -s wttr.in/Moon";
      more = "${pkgs.bat}/bin/bat";
      pq = "${pkgs.pueue}/bin/pueue";
      ruler = ''${pkgs.hr}/bin/hr "╭─³⁴⁵⁶⁷⁸─╮"'';
      screenfetch = "${pkgs.fastfetch}/bin/fastfetch";
      speedtest = "${pkgs.speedtest-go}/bin/speedtest-go";
      store-path = "${pkgs.coreutils-full}/bin/readlink (${pkgs.which}/bin/which $argv)";
      top = "${pkgs.bottom}/bin/btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
      tree = "${pkgs.eza}/bin/eza --tree";
      qr = "curl -F-=\<- qrenco.de";
      netcount = "netstat -ntu | tail -n +3 | awk '{print $5}' | sed 's/:[0-9]*$//' | sort | uniq -c | sort -rn";
    };
    shellInit =
      let
        theme = import ../common/theme.nix { inherit config; };
        inherit (theme) colors;
        # Strip '#' for fish color commands
        c = lib.mapAttrs (_: v: lib.removePrefix "#" v) colors;
      in
      ''
        set fish_greeting ""

        # Rose Pine colors for fish
        set -g fish_color_normal ${c.text}
        set -g fish_color_command ${c.foam}
        set -g fish_color_quote ${c.gold}
        set -g fish_color_redirection ${c.iris}
        set -g fish_color_end ${c.muted}
        set -g fish_color_error ${c.love}
        set -g fish_color_param ${c.rose}
        set -g fish_color_comment ${c.muted}
        set -g fish_color_match ${c.pine}
        set -g fish_color_selection --background=${c.overlay}
        set -g fish_color_search_match --background=${c.overlay}
        set -g fish_color_history_current --bold
        set -g fish_color_operator ${c.pine}
        set -g fish_color_escape ${c.love}
        set -g fish_color_cwd ${c.pine}
        set -g fish_color_cwd_root ${c.love}
        set -g fish_color_valid_path --underline
        set -g fish_color_autosuggestion ${c.muted}
        set -g fish_color_user ${c.foam}
        set -g fish_color_host ${c.pine}
        set -g fish_color_cancel ${c.love}
        set -g fish_pager_color_prefix ${c.iris}
        set -g fish_pager_color_completion ${c.text}
        set -g fish_pager_color_description ${c.muted}
        set -g fish_pager_color_progress ${c.foam}
        set -g fish_pager_color_secondary --background=${c.surface}
      '';
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      command_timeout = 500;
    };
  };
}
