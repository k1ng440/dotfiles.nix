{pkgs, ...}: {
  programs.git = {
    enable = true;
    userName = "Asaduzzaman Pavel";
    userEmail = "contact@iampavel.dev";
    aliases = {
      co = "checkout";
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
