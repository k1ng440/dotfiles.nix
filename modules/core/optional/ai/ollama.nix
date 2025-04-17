{
  unstable,
  ...
}:
{
  services.ollama = {
    package = unstable.ollama-cuda;
    enable = true;
    acceleration = "cuda";
    environmentVariables = {
      OLLAMA_ORIGINS = "chrome-extension://*,moz-extension://*,safari-web-extension://*";
      OLLAMA_LLM_LIBRARY = "cuda_v12";
      OLLAMA_KV_CACHE_TYPE = "16f";
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_CONTEXT_LENGTH = "8192";
    };
  };
}
