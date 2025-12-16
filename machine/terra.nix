{
  lib,
  ...
}:
{
  imports = lib.listFilePaths ./terra;
  config = {
    networking.publicAddresses = [
      "107.205.77.253"
    ];
  };
  meta = { };
}
