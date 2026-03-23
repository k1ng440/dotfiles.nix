{ inputs, lib, ... }:
let
  privateMatchBlocks = lib.custom.getSecret inputs "nix-secrets" "programs.ssh.matchBlocks" { };

  publicMatchBlocks = {
    "github.com gitlab.com bitbucket.org git.sr.ht" = {
      user = "git";
    };
  };
  allNamedBlocks = builtins.attrNames (publicMatchBlocks // privateMatchBlocks);
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = lib.mkMerge [
      {
        "*" = lib.hm.dag.entryAfter allNamedBlocks {
          forwardAgent = false;
          serverAliveInterval = 60;
          serverAliveCountMax = 3;
          compression = true;
          extraOptions = {
            AddKeysToAgent = "yes";
            ControlMaster = "auto";
            ControlPath = "~/.ssh/master-%r@%h:%p";
            ControlPersist = "10m";
          };
        };
      }
      publicMatchBlocks
      privateMatchBlocks
    ];
  };
}
