{ lib, pkgs, config, ... }:
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
      lm = "${pkgs.lima-bin}/bin/limactl";
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
    };
    shellInit = ''
      set fish_greeting ""
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
