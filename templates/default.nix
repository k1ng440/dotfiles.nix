let
  go = {
    path = ./go;
    description = "Go module template with perSystem packages pattern";
  };

  python = {
    path = ./python;
    description = "Python application template with perSystem packages pattern";
  };

  typescript = {
    path = ./typescript;
    description = "TypeScript/Node.js application template with perSystem packages pattern";
  };

  bun = {
    path = ./bun;
    description = "Bun + Playwright dev shell template";
  };
in
{
  inherit
    go
    python
    typescript
    bun
    ;
  py = python;
  ts = typescript;
  node = typescript;
}
