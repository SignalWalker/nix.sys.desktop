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
  config = lib.mkIf false {
    services.calibre-server = {
      enable = true;
      libraries = ["/elysium/media/text/book"];
      host = "127.0.0.1";
      port = 40507;
      auth = {
        enable = true;
        mode = "basic";
      };
    };

    services.calibre-web = {
      enable = true;
      listen = {
        ip = "127.0.0.1";
        port = 40508;
      };
      openFirewall = false;
      options = {
        calibreLibrary = head calibre.libraries;
        reverseProxyAuth = {
          enable = false;
        };
      };
    };

    # system.aclMap = std.genAttrs calibre.libraries (library: {
    #   entries = map (user: {
    #     type = "user";
    #     entity = user;
    #     read = true;
    #     write = true;
    #     execute = true;
    #   }) [calibre.user web.user];
    #   recursive = true;
    #   append = true;
    # });

    services.nginx.virtualHosts."library.books.home.ashwalker.net" = {
      enableACME = true;
      forceSSL = true;
      listenAddresses = config.services.nginx.publicListenAddresses;
      extraConfig = ''
        client_max_body_size 64M;
      '';
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString calibre.port}";
      };
    };
    services.nginx.virtualHosts."books.home.ashwalker.net" = {
      enableACME = true;
      forceSSL = true;
      listenAddresses = config.services.nginx.publicListenAddresses;
      extraConfig = ''
        client_max_body_size 64M;
      '';
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString web.listen.port}";
      };
    };
  };
  meta = {};
}
