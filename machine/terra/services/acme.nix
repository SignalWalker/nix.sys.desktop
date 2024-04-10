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
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "admin@ashwalker.net";
      };
    };
  };
  meta = {};
}
