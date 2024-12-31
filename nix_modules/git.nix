{pkgs, ...}: {
  programs.git = {
    enable = true;
    userName = "Asaduzzaman Pavel";
    userEmail = "contact@iampavel.dev";
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
  };
}
