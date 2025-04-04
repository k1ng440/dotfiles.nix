local project_root = vim.fs.root(0, {
    ".git",
})

vim.lsp.config["nix"] = {
    settings = {
        nixpkgs = {
            expr = "import <nixpkgs> { }",
        },
        formatting = {
            command = { "nixfmt" },
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
