{ lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    # ai subs derivation to allow overriding
    let
      aiSubsDrv =
        {
          writeShellApplication,
          whisper-ctranslate2,
        }:
        writeShellApplication {
          name = "ai-subs";
          runtimeInputs = [ whisper-ctranslate2 ];
          # int8 is the fastest on cpu, according to the project page
          text = /* sh */ ''
            whisper-ctranslate2 --language en --output_format srt --compute_type int8 --model medium "$@"
          '';
        };
    in
    {
      packages.ai-subs = pkgs.callPackage aiSubsDrv { };
    };

  flake.modules.nixos.programs_subtitles =
    { pkgs, ... }:
    lib.mkMerge [
      # subliminal
      {
        # TODO: remove once hyperpyyaml is updated for ruamel-yaml >= 0.19
        environment = {
          systemPackages = [
            pkgs.python3Packages.subliminal
            pkgs.custom.ai-subs
          ];

          shellAliases = {
            subs = "subliminal download -l 'en' -l 'eng' -s";
          };
        };
      }

      # openai-whisper for transcribing audio / video
      {
        environment.systemPackages = with pkgs; [
          whisper-ctranslate2
        ];

        custom.persist = {
          home.directories = [
            ".cache/huggingface"
          ];
        };
      }
    ];
}
