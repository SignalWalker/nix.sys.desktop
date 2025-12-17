{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = lib.listFilePaths ./theia;
  config = { };
  meta = { };
}

