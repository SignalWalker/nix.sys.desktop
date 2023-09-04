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
  imports = lib.signal.fs.path.listFilePaths ./groceries;
  config = {
    services.grocy-signal = {
      enable = true;
      nginx = {
        hostName = "groceries.home.ashwalker.net";
        enableACME = true;
        forceSSL = true;
      };
    };
  };
  meta = {};
}
