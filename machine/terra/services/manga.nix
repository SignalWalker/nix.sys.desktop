{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  komga = config.services.komga;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = {
    services.komga = {
      enable = true;
      port = 40607;
      openFirewall = false;
    };
    services.nginx.virtualHosts."manga.home.ashwalker.net" = {
      useACMEHost = "home.ashwalker.net";
      forceSSL = true;
      listenAddresses = config.services.nginx.publicListenAddresses;
      locations."/".proxyPass = "http://127.0.0.1:${toString komga.port}";
    };
  };
  meta = {};
}