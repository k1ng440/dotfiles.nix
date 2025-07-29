# TODO: Make this a module to use with other hosts.
{
  pkgs,
  lib,
  config,
  ...
}:
let
  machine = config.machine;

  repos = {
    # TODO:  Move this to machine
    kong = "ssh://pavel@192.168.0.10//masterpool/backup";
  };

  borgDefaults = {
    encryption = {
      mode = "repokey-blake2";
    };
    environment = {
      BORG_RSH = "ssh -o 'StrictHostKeyChecking=no' -i ${config.sops.secrets."ssh/borgbackup".path}";
      BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK = "yes";
    };
    extraCreateArgs = "--verbose --stats --checkpoint-interval 600";
    compression = "auto,zstd";
    startAt = "daily";
    user = "root";
  };

  excludePatterns = {
    cache = [
      ".cache"
      "*/cache2" # firefox
      "*/Cache"
      ".config/Slack/logs"
      ".config/Code/CachedData"
      ".container-diff"
      ".npm/_cacache"
      "*/node_modules"
      "*/bower_components"
    ];

    build = [
      "*/_build"
      "*/.tox"
      "*/venv"
      "*/.venv"
    ];

    userSpecific = [
      "Downloads"
      "Music"
      ".steam"
      ".ollama"
      ".npm"
      ".nv"
      ".java"
      "go"
      ".anydesk"
      ".android"
      ".ansible"
      ".dartServer"
      "Pictures/Screenshots"
      "Pictures/Wallpapers"
      ".thunderbird"
      ".sane"
      ".pub-cache"
      ".factorio.bak"
    ];
  };

  mkExcludePaths = basePath: patterns: map (pattern: "${basePath}/${pattern}") patterns;

  mkBorgJob =
    {
      name,
      repo,
      paths,
      passphraseFile,
      excludeCategories ? [
        "cache"
        "build"
      ],
      extraExcludes ? [ ],
      overrides ? { },
    }:
    let
      selectedExcludes = lib.concatLists (map (cat: excludePatterns.${cat}) excludeCategories);
      allExcludes = selectedExcludes ++ extraExcludes;
      excludePaths = mkExcludePaths paths allExcludes;
    in
    borgDefaults
    // {
      encryption = borgDefaults.encryption // {
        passCommand = "cat ${passphraseFile}";
      };
      repo = "${repo}/${name}";
      inherit paths;
      exclude = excludePaths;
    }
    // overrides;
in
{
  environment.systemPackages = with pkgs; [ borgbackup ];

  services.borgbackup.jobs = {
    home-primary = mkBorgJob {
      name = "${machine.hostname}/${machine.username}-home";
      repo = repos.kong;
      paths = "/home/${machine.username}/";
      passphraseFile = config.sops.secrets."borgbackup/encryption_key".path;
      excludeCategories = [
        "cache"
        "build"
        "userSpecific"
      ];
      overrides = {
        user = machine.username;
      };
    };
  };
}
