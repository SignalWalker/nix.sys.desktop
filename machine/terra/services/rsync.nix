{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  rsync = config.services.rsyncd;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = {
    services.rsyncd = {
      enable = false;
      socketActivated = true;
      settings = {
      };
    };
  };
  meta = {};
}
