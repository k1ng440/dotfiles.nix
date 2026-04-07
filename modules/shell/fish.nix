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

            # Navigation
            ".." = "cd ..";
            "..." = "cd ../..";
            "...." = "cd ../../..";
            "-" = "cd -";

            # Git shortcuts
            gs = "git status";
            ga = "git add";
            gc = "git commit";
            gp = "git push";
            gl = "git log --oneline --graph -20";
            gd = "git diff";

            # History and process management
            hg = "history | grep";
            pg = "ps aux | grep -v grep | grep -i";
            port = "netstat -tuln | grep";

            # Archives
            untar = "tar -xvf";

            # ls variants
            lsn = "ls -lv";
          };
          shellInit = /* fish */ ''
            set fish_greeting
            function fish_user_key_bindings
                fish_default_key_bindings -M insert
                fish_vi_key_bindings --no-erase insert
                bind -M insert ! bind_bang
                bind -M insert '$' bind_dollar
            end
            fish_vi_key_bindings
            source ${fish-completion-sync}/init.fish

            function bind_bang
                switch (commandline -t)
                    case "!"
                        commandline -t -- $history[1]
                        commandline -f repaint
                    case "*"
                        commandline -i !
                end
            end

            function bind_dollar
                switch (commandline -t)
                    case "!"
                        commandline -t ""
                        commandline -f backward-delete-char
                        commandline -i -- (string split ' ' -- $history[1])[-1]
                        commandline -f repaint
                    case "*"
                        commandline -i '$'
                end
            end

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

            # Create directory and cd into it
            function mkcd
                mkdir -p $argv[1] && cd $argv[1]
            end

            # Extract any archive
            function extract
                if test -f $argv[1]
                    switch $argv[1]
                        case '*.tar.bz2'
                            tar -xjf $argv[1]
                        case '*.tar.gz'
                            tar -xzf $argv[1]
                        case '*.tar.xz'
                            tar -xJf $argv[1]
                        case '*.bz2'
                            bunzip2 $argv[1]
                        case '*.rar'
                            unrar x $argv[1]
                        case '*.gz'
                            gunzip $argv[1]
                        case '*.tar'
                            tar -xf $argv[1]
                        case '*.tbz2'
                            tar -xjf $argv[1]
                        case '*.tgz'
                            tar -xzf $argv[1]
                        case '*.zip'
                            unzip $argv[1]
                        case '*.Z'
                            uncompress $argv[1]
                        case '*.7z'
                            7z x $argv[1]
                        case '*'
                            echo "Unknown archive: $argv[1]"
                    end
                else
                    echo "'$argv[1]' is not a valid file"
                end
            end

            # Find and edit files with fzf
            function fe
                set -l files (fzf --query="$argv[1]" --multi --select-1 --exit-0 | string split \n)
                if test -n "$files"
                    $EDITOR $files
                end
            end

            # Quick HTTP server
            function serve
                set -l port (test -n "$argv[1]"; and echo $argv[1]; or echo 8000)
                python3 -m http.server $port
            end

            # Create backup with timestamp
            function backup
                cp $argv[1] $argv[1].(date +%Y%m%d_%H%M%S).bak
            end

            # Tmux: attach or create session
            function ta
                if test -z "$argv[1]"
                    tmux new-session -A -s main
                else
                    tmux new-session -A -s $argv[1]
                end
            end

            # Tmux: create new session with current directory name
            function tn
                set -l session_name (test -n "$argv[1]"; and echo $argv[1]; or basename (pwd))
                tmux new-session -d -s $session_name 2>/dev/null; or true
                tmux attach -t $session_name
            end

            # Tmux: list and attach to session
            function tl
                tmux list-sessions -F "#S" 2>/dev/null | fzf --select-1 --exit-0 | read -l session
                if test -n "$session"
                    tmux attach -t $session
                end
            end

            # Tmux: kill session
            function tk
                if test -z "$argv[1]"
                    tmux list-sessions -F "#S" 2>/dev/null | fzf -m | read -l session
                    if test -n "$session"
                        tmux kill-session -t $session
                    end
                else
                    tmux kill-session -t $argv[1]
                end
            end

            # Checkout git branches with fzf
            function fbr
                git branch -a | grep -v HEAD | fzf | read -l branch
                if test -n "$branch"
                    set -l clean_branch (echo $branch | sed 's/.* //' | sed 's#remotes/[^/]*/##')
                    git checkout $clean_branch
                end
            end

            # Network utilities
            function myip
                curl -s https://ipinfo.io/ip
            end

            function ips
                ip -br -c addr show
            end

            function ports
                if test -n "$argv[1]"
                    ss -tlnp | grep ":$argv[1]"
                else
                    ss -tlnp
                end
            end

            function dns
                dig +short $argv[1]
            end

            # Cross-platform clipboard copy
            function copy
                set -l input (test -n "$argv[1]"; and echo $argv[1]; or cat)

                if command -q pbcopy
                    echo -n $input | pbcopy
                else if command -q wl-copy
                    echo -n $input | wl-copy
                else if command -q xclip
                    echo -n $input | xclip -selection clipboard
                else if command -q xsel
                    echo -n $input | xsel --clipboard --input
                else
                    echo "No clipboard utility found. Install wl-copy, xclip, or xsel." >&2
                    return 1
                end
            end

            # Check disk space above threshold
            function diskalert
                set -l threshold (test -n "$argv[1]"; and echo $argv[1]; or echo 80)
                df -h | awk -v threshold=$threshold 'NR>1 {
                    gsub(/%/,"",$5)
                    if ($5 > threshold) {
                        print "WARNING: " $6 " is at " $5 "% capacity (" $3 " used of " $2 ")"
                    }
                }'
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
