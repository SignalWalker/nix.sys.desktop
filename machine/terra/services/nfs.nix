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
  imports = [];
  config = {
    services.nfs = {
      server = {
        enable = true;
        hostName = "172.24.86.1";
      };
    };
  };
  meta = {};
}
