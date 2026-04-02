{
  flake.modules.nixos.core =
    {
      config,
      pkgs,
      ...
    }:
    let
      # reloads fish completions whenever directories are added to $XDG_DATA_DIRS,
      # e.g. in nix shells or direnv
      fish-completion-sync = pkgs.fetchFromGitHub {
        owner = "iynaix";
        repo = "fish-completion-sync";
        rev = "4f058ad2986727a5f510e757bc82cbbfca4596f0";
        hash = "sha256-kHpdCQdYcpvi9EFM/uZXv93mZqlk1zCi2DRhWaDyK5g=";
      };
    in
    {
      programs = {
        fish = {
          enable = true;
          # Seems like shell abbreviations take precedence over aliases
          shellAbbrs = config.environment.shellAliases // {
            ehistory = ''nvim "${config.hj.xdg.data.directory}/fish/fish_history"'';

            # fzf + neovim
            vf = /* sh */ "fzf --preview 'bat --color=always {}' --preview-window=right:60% | xargs -r nvim";
            fkill = /* sh */ "ps aux | fzf --header-lines=1 | awk '{print $2}' | xargs -r kill -9";
          };
          shellInit = /* fish */ ''
            set fish_greeting
            function fish_user_key_bindings
                fish_default_key_bindings -M insert
                fish_vi_key_bindings --no-erase insert
            end
            fish_vi_key_bindings
            source ${fish-completion-sync}/init.fish

            function last_history_item
                echo $history[1]
            end
            abbr -a !! --position anywhere --function last_history_item

            function glog
                git log --oneline | fzf \
                    --preview 'git show --color=always {1}' \
                    --bind 'enter:execute(git show {1} | nvim -)'
            end

            function vr
                set file (nvim --headless +'lua io.write(table.concat(vim.v.oldfiles, "\n"))' +qa 2>/dev/null \
                    | fzf --preview 'bat --color=always {}')
                test -n "$file" && nvim "$file"
            end

            function fd
                set dir (find . -type d | fzf --preview 'ls -la {}')
                test -n "$dir" && cd "$dir"
            end

            function fmake
                if not test -f Makefile
                    echo "No Makefile found in current directory"
                    return 1
                end
                set -l target (grep -E '^[a-zA-Z0-9_-]+:' Makefile | cut -d: -f1 | fzf --header 'Run make target')
                test -n "$target"; and make $target
            end

            function frg
                set -l result (rg --line-number --column --no-heading --color=always --smart-case "$argv" | fzf --ansi --delimiter : --preview 'bat --color=always --highlight-line {2} {1}' --preview-window 'up,60%,border-bottom,+{2}+3/3')
                if test -n "$result"
                    set -l file (echo $result | cut -d: -f1)
                    set -l line (echo $result | cut -d: -f2)
                    nvim +$line $file
                end
            end
          '';
        };
      };

      # fish plugins
      environment = {
        # install fish completions for fish
        # https://github.com/nix-community/home-manager/pull/2408
        pathsToLink = [ "/share/fish" ];

        systemPackages = [
          fish-completion-sync
        ];
      };

      custom.persist = {
        home = {
          # fish history
          cache.directories = [ ".local/share/fish" ];
        };
      };
    };
}
