{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkMerge [
    (lib.mkIf config.machine.services.ai.ollama {
      services.ollama = {
        enable = true;
        package = pkgs.ollama-cuda;
        host = "0.0.0.0";
        environmentVariables = {
          OLLAMA_ORIGINS = "http://localhost:*,http://127.0.0.1:*,chrome-extension://*,moz-extension://*,safari-web-extension://*";
          OLLAMA_LLM_LIBRARY = "cuda_v12";
          OLLAMA_KV_CACHE_TYPE = "q4_0";
          OLLAMA_FLASH_ATTENTION = "1";
          OLLAMA_CONTEXT_LENGTH = "32768";
        };
      };
    })
    (lib.mkIf config.machine.services.ai.open-webui {
      services.open-webui = {
        enable = true;
        port = 11111;
        package = pkgs.unstable.open-webui;
        environment = {
          OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
          WEBUI_AUTH = "False";
          ANONYMIZED_TELEMETRY = "False";
          DO_NOT_TRACK = "True";
          SCARF_NO_ANALYTICS = "True";
        };
      };
    })
    (lib.mkIf config.machine.services.ai.wan2gp {
      environment.systemPackages = [ pkgs.wan2gp ];
    })
  ];
}
