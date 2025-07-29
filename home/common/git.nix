{ pkgs, machine, ... }:
{
  home.packages = with pkgs; [
    meld # Visual diff and merge tool
  ];

  programs = {
    gh.enable = true;
    lazygit.enable = true;

    git = {
      enable = true;
      userName = machine.userFullName;
      userEmail = machine.email.work;
      aliases = {
        co = "checkout";
        ec = "config --global -e";
        ppr = "pull --rebase --prune";
        cob = "checkout -b";
        rb = "branch -m";
        cm = "!git add -A && git commit -m";
        amend = "commit -a --amend";
        save = "!git add -A && git commit -m 'SAVEPOINT'";
        wip = "commit -am 'WIP' --no-verify";
        undo = "reset HEAD~1 --mixed";
        wipe = "!git add -A && git commit -qm 'WIPE SAVEPOINT' && git reset HEAD~1 --hard";
        po = "push origin";
        st = "status";
        unstage = "reset HEAD --";
        ponv = "po --no-verify";
        last = "log -1 HEAD";
        stasha = "stash --all"; # stash even untracked and ignored files
        pushf = "push --force-with-lease"; # only force pushes if no new commits have pushed after the last pull
        l = "log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all -n 15";
        graph = "log --graph --decorate --oneline";
        map = "!git graph --all";
        watch = "!watch -ct 'git -c color.status=always status -s && echo && git map --color'";
      };
      ignores = [
        "*~"
        "*.swp"
      ];
      extraConfig = {
        rerere = {
          enabled = true;
        };
        init = {
          defaultBranch = "master";
        };
      };
      diff-so-fancy = {
        enable = true;
      };
      lfs = {
        enable = true;
        skipSmudge = true;
      };
    };
  };
}
