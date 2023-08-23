{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  calibre = config.services.calibre-server;
  web = config.services.calibre-web;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = {
    services.calibre-server = {
      enable = true;
      libraries = ["/elysium/media/text/book"];
      host = "::1";
      port = 40507;
      auth = {
        enable = false;
      };
    };
    services.nginx.virtualHosts."books.home.ashwalker.net" = {
      extraConfig = ''
        client_max_body_size 64M;
      '';
      location."/" = {
        proxyPass = "http://[::1]:${toString calibre.port}";
      };
    };
  };
  meta = {};
}
