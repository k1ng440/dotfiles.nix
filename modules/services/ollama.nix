_: {
  flake.modules.nixos.services_ollama =
    {
      lib,
      config,
      ...
    }:
    {
      services.ollama = {
        enable = true;
        acceleration = "cuda";
        loadModels = [
          "tinyllama"
        ];
        host = "127.0.0.1";
        port = 11434;
      };

      # Your standard UI/Persistence pattern
      custom = {
        programs.which-key.menus = {
          a = {
            desc = "AI";
            submenu = {
              o = {
                desc = "Ollama CLI";
                cmd = "${lib.getExe config.services.ollama.package} run deepseek-r1:1.5b";
              };
              l = {
                desc = "List Models";
                cmd = "${lib.getExe config.services.ollama.package} list";
              };
            };
          };
        };

        persist = {
          state.directories = [
            # Matches the 'StateDirectory' defined in your module
            "/var/lib/ollama"
          ];
        };
      };
    };
}
