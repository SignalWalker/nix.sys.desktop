{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  grocy = config.services.grocy;
in {
  options = with lib; {};
  disabledModules = [];
  imports = lib.listFilePaths ./groceries;
  config = {
    services.grocy-signal = {
      enable = false;
      nginx = {
        hostName = "groceries.home.ashwalker.net";
        enableACME = true;
        forceSSL = true;
      };
    };
  };
  meta = {};
}