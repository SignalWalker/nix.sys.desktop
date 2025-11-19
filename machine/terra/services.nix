{
  lib,
  ...
}:
{
  imports = lib.listFilePaths ./services;
}

