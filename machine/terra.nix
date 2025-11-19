{
  lib,
  ...
}:
{
  imports = lib.listFilePaths ./terra;
  config = {
    networking.publicAddresses = [
      "24.98.17.92"
    ];
  };
  meta = { };
}

