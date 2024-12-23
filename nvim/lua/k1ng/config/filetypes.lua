vim.filetype.add({
  extension = {
    rasi = 'rasi',
    rofi = 'rasi',
    wofi = 'rasi',
  },
  filename = {
    ['.env'] = 'sh',
    ['.env.example'] = 'sh',
    ['vifmrc'] = 'vim',
    ['.eslintrc.json'] = 'jsonc',
  },
  pattern = {
    ['tsconfig*.json'] = 'jsonc',
    ['.*/waybar/config'] = 'jsonc',
    ['.*/mako/config'] = 'dosini',
    ['.*/kitty/.+%.conf'] = 'bash',
    ['.*/hypr/.+%.conf'] = 'hyprlang',
    ['%.env%.[%w_.-]+'] = 'sh',
    ['.*%.ya?ml%.j2'] = 'yaml',
    -- ansible
    ['.*/host_vars/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/group_vars/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/group_vars/.*/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/playbooks/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/roles/.*/tasks/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/roles/.*/handlers/.*%.ya?ml'] = 'yaml.ansible',
    -- systemd
    ['.*%.service'] = 'systemd',
    ['.*%.service%.j2'] = 'systemd',
  },
})