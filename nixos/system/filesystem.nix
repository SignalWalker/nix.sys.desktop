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
    # essentially a file manager interface to udisks
    services.gvfs = {
      enable = true;
    };
    services.tumbler = {
      # dbus thumbnail service
      enable = true;
    };
  };
  meta = {};
}
