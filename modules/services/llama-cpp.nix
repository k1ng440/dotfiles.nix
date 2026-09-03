_: {
  perSystem =
    { pkgs, ... }:
    {
      packages.llama-cpp =
        (pkgs.llama-cpp.overrideAttrs (_attrs: rec {
          version = "10690";
          src = pkgs.fetchFromGitHub {
            owner = "ggml-org";
            repo = "llama.cpp";
            tag = "b${version}";
            hash = "sha256-76y67z08349NtKbzup90z25SwS65bB5UPiO+uWTfsTc=";
          };
          npmDepsHash = "sha256-2Q7XhaLAArmviOLdQsNbYTfdyDE5pW9lR26cRHEVl9k=";
        })).override
          { cudaSupport = true; };

      # packages.llama-cpp =
      #   (pkgs.llama-cpp.overrideAttrs (attrs: rec {
      #     version = "0.4.4";
      #     src = pkgs.fetchFromGitHub {
      #       owner = "Anbeeld";
      #       repo = "beellama.cpp";
      #       tag = "v${version}";
      #       hash = "sha256-NjPXKiImZO7x5rsDpzt9ToQsgW6xLjob0wOX/DXfY7g=";
      #     };
      #     npmDepsHash = "sha256-2Q7XhaLAArmviOLdQsNbYTfdyDE5pW9lR26cRHEVl9k=";
      #     cmakeFlags = (attrs.cmakeFlags or [ ]) ++ [
      #       "-DGGML_CUDA_FA=ON"
      #     ];
      #   })).override
      #     { cudaSupport = true; };
    };

  flake.modules.nixos.services_llama-cpp =
    {
      pkgs,
      lib,
      ...
    }:
    let
      modelPath = "/var/lib/llama-cpp/models/Qwen3.8-27B-i1-IQ4_XS-GGUF-Smaller.gguf";
      modelName = "Qwen3.8-27B";
      modelJinja = "/var/lib/llama-cpp/templates/chat_template.jinja";
      port = 10888;
      contextSize = 8192;
      gpuLayers = 35;
    in
    {
      nixpkgs.overlays = [
        (_: _prev: { inherit (pkgs.custom) llama-cpp; })
      ];

      environment.systemPackages = [
        pkgs.llama-cpp
        pkgs.python312Packages.huggingface-hub
      ];

      users.users.llama-cpp = {
        isSystemUser = true;
        group = "llama-cpp";
        home = "/var/lib/llama-cpp";
        createHome = true;
      };
      users.groups.llama-cpp = { };

      systemd.tmpfiles.rules = [
        "d /var/lib/llama-cpp/models 0755 llama-cpp llama-cpp -"
      ];

      systemd.services.llama-server = {
        description = "llama.cpp inference server (CUDA)";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        serviceConfig = {
          Type = "simple";
          User = "llama-cpp";
          Group = "llama-cpp";

          ExecStart = lib.concatStringsSep " " [
            "${pkgs.llama-cpp}/bin/llama-server"
            "--model ${modelPath}"
            "--alias ${modelName}"
            "--n-gpu-layers ${toString gpuLayers}"
            "--host 127.0.0.1"
            "--port ${toString port}"
            "--reasoning-preserve"
            "--temp 1.0"
            "--top-p 0.95"
            "--top-k 20"
            "--min-p 0.0"
            "--presence-penalty 0.0"
            "--repeat-penalty 1.0"
            "--parallel 1"
            "--batch-size 1024"
            "--ubatch-size 256"
            "--flash-attn on"
            "--spec-type draft-mtp"
            "--spec-draft-n-max 2"
            "--cache-type-k q4_0"
            "--cache-type-v q4_0"
            "--ctx-size ${toString contextSize}"
            "--jinja"
            ''--chat-template-kwargs "{\"preserve_thinking\": true, \"reasoning_effort\":\"medium\"}"''
            "--chat-template-file ${toString modelJinja}"
            "--no-mmproj-offload"
            "--threads 7"
            "--threads-batch 8"
            "--metrics"
            "--verbosity 3"
            "--perf"
          ];
          Restart = "on-failure";
          RestartSec = "10s";

          # Model loading reads several GB from disk; don't let systemd give up early.
          TimeoutStartSec = "300s";

          # Hardening. Relaxed where the NVIDIA stack requires it — the driver needs
          # device nodes under /dev, so full device isolation is not available here.
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          ReadWritePaths = [ "/var/lib/llama-cpp" ];
          ProtectKernelTunables = true;
          ProtectControlGroups = true;
          RestrictNamespaces = true;
          RestrictRealtime = true;
          LockPersonality = true;
        };
      };
    };
}
