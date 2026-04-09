{ lib, ... }:
{
  flake.modules.nixos.doppler =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.doppler ];

      programs = {
        bash.interactiveShellInit = /* sh */ ''
          if [[ :$SHELLOPTS: =~ :(vi|emacs): ]]; then
            eval "$(${lib.getExe pkgs.doppler} completion bash)"
          fi
        '';

        fish.interactiveShellInit = /* fish */ ''
          ${lib.getExe pkgs.doppler} completion fish | source
        '';
      };

      custom.persist = {
        home = {
          directories = [ ".doppler" ];
        };
      };
    };
}
