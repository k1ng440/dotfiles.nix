{
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv) isLinux;
in
{
  programs.fish = {
    enable = true;
    shellAliases = {
      ".." = "cd ..";
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
      ls = "${pkgs.eza}/bin/eza --icons=auto --group-directories-first";
      ll = "${pkgs.eza}/bin/eza --icons=auto --group-directories-first -l";
      la = "${pkgs.eza}/bin/eza --icons=auto --group-directories-first -a";
      lt = "${pkgs.eza}/bin/eza --icons=auto --group-directories-first --tree";
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
      shutdown = "systemctl poweroff";
    };
    shellAbbrs = {
      # Git
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit -m";
      gp = "git push";
      gl = "git pull";
      gpl = "git pull";
      gd = "git diff";
      gb = "git branch";
      gco = "git checkout";
      gcheck = "git checkout";
      gst = "git stash";
      gsp = "git stash; git pull";
      gfo = "git fetch origin";
      gcredential = "git config credential.helper store";

      # Nix
      n = "nix";
      nr = "nix run";
      ns = "nix shell";
      nb = "nix build";
      nfl = "nix flake lock";
      nfu = "nix flake update";
      # nh
      nhos = "nh os switch";
      nhh = "nh home switch";
    };
    shellInit = ''
      set fish_greeting ""
    '';
    functions = {
      # Extract any archive easily using ouch
      extract = {
        body = ''
          if count $argv > /dev/null
            for file in $argv
              if test -f $file
                echo "Extracting $file..."
                ouch decompress $file
              else
                echo "'$file' is not a valid file"
              end
            end
          else
            echo "Usage: extract <file1> [<file2> ...]"
          end
        '';
      };

      # Create a directory and enter it
      mkcd = {
        body = "mkdir -p $argv; and cd $argv";
      };

      # Yazi wrapper to change directory on exit
      yy = {
        body = # lang: fish
          ''
            set tmp (mktemp -t "yazi-cwd.XXXXXX")
            yazi $argv --cwd-file="$tmp"
            if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
              builtin cd -- "$cwd"
            end
            rm -f -- "$tmp"
          '';
      };
    };
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = true;
      command_timeout = 500;
    };
  };
}
