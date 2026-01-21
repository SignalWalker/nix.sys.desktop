{
  lib,
  ...
}:
{
  imports = lib.listFilePaths ./network;
}
