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
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql;
      extraPlugins = with pkgs.postgresql.pkgs; [];
    };
  };
  meta = {};
}
