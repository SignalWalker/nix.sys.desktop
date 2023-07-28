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
  imports = lib.signal.fs.path.listFilePaths ./services;
  config = {
    services.dbus = {
      enable = true;
      implementation = "broker";
    };
  };
  meta = {};
}
