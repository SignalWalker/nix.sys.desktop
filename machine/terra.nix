{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
in {
  options = with lib; {};
  disabledModules = [];
  imports = lib.signal.fs.path.listFilePaths ./terra;
  config = {
    networking.publicAddresses = [
      "24.98.17.92"
    ];
  };
  meta = {};
}
