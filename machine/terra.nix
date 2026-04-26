{
  lib,
  ...
}:
{
  imports = lib.listFilePaths ./terra;
  config = {
    networking.publicAddresses = [
      "152.44.240.6"
    ];
  };
  meta = { };
}
