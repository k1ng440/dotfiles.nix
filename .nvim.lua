if vim.fn.has('0.11.0') == 1 then
  local project_root = vim.fs.root(0, {
      ".git",
  })

  vim.lsp.config["nix"] = {
      settings = {
          nixpkgs = {
            expr = 'import (builtins.getFlake "' .. project_root .. '").inputs.nixpkgs { }   '
          },
          formatting = {
              command = { "nix", "fmt" },
          },
          options = {
              nixos = {
                  expr = '(builtins.getFlake "' .. project_root .. '").nixosConfigurations.xenomorph.options',
              },
              flake_parts = {
                  expr = '(builtins.getFlake "' .. project_root .. '").debug.options',
              },
              flake_parts2 = {
                  expr = '(builtins.getFlake "' .. project_root .. '").currentSystem.options',
              },
              home_manager = {
                  expr = '(builtins.getFlake "' .. project_root .. '").homeConfigurations."k1ng@xenomorph".options',
              },
          },
      },
  }

  vim.cmd [[
    set makeprg=nix\ flake\ check\ --show-trace
  ]]
end
