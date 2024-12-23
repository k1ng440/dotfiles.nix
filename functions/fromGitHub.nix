{pkgs, user, repo, ref, rev, buildScript ? ":"}: 
pkgs.vimUtils.buildVimPlugin {
  pname = "${pkgs.lib.strings.sanitizeDerivationName repo}"; 
  version = ref;
  src = builtins.fetchGit { 
    url = "https://github.com/${user}/${repo}.git";
    rev = rev;
    inherit ref;
  };
  inherit buildScript;
}
