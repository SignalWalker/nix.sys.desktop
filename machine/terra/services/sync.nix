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
    services.atuin = {
      enable = true;
      host = "0.0.0.0";
      openRegistration = false;
      openFirewall = true;
      port = 8398;
    };
  };
  meta = {};
}
