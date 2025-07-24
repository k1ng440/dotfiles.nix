{
  pkgs,
  ...
}:
{
  services.ollama = {
    package = pkgs.unstable.ollama-cuda;
    enable = true;
    acceleration = "cuda";
    environmentVariables = {
      OLLAMA_ORIGINS = "chrome-extension://*,moz-extension://*,safari-web-extension://*";
      OLLAMA_LLM_LIBRARY = "cuda_v12";
      OLLAMA_KV_CACHE_TYPE = "q4_0";
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_CONTEXT_LENGTH = "32768";
    };
  };

  services.open-webui = {
    enable = false;
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
}
