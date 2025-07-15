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
  imports = lib.listFilePaths ./terra;
  config = {
    networking.publicAddresses = [
      "24.98.17.92"
    ];
  };
  meta = {};
}