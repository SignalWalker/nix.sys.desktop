{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  homepage = config.services.homepage-dashboard;
  domain = "home.terra.ashwalker.net";
in {
  options = with lib; {
  };
  disabledModules = [];
  imports = [];
  config = {
    # services.homepage-dashboard = {
    #   enable = false;
    #   listenPort = 30801;
    #   openFirewall = lib.mkForce false;
    #   startUrl = "http://${domain}";
    # };
  };
  meta = {};
}
