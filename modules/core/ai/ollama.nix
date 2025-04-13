{inputs, pkgs, unstable, config, ...}: {
  services.nextjs-ollama-llm-ui = {
    package = unstable.nextjs-ollama-llm-ui;
    enable = true;
  };

  services.ollama = {
    package = unstable.ollama-cuda;
    enable = true;
    acceleration = "cuda";
    environmentVariables = {
      OLLAMA_ORIGINS = "chrome-extension://*,moz-extension://*,safari-web-extension://*";
      OLLAMA_LLM_LIBRARY = "cuda_v12";
    };
  };
}
