" Turn off syntax highlighting for large YAML files.
if line('$') > 5000
  setlocal syntax=OFF
endif
