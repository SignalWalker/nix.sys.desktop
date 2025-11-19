{
  config,
  pkgs,
  lib,
  ...
}:
let
  calibre = config.services.calibre-server;
  web = config.services.calibre-web;
  # kavita = config.services.kavita;
in
{
  config = {
    services.calibre-server = {
      enable = true;
      package = pkgs.calibre.override {
        unrarSupport = true;
      };
      libraries = [ "/elysium/media/text/book" ];
      host = "127.0.0.1";
      port = 40507;
      openFirewall = false;
      auth = {
        enable = true;
        mode = "basic";
      };
      extraFlags = [
        "--enable-use-sendfile"
        "--enable-use-bonjour"
      ];
    };

    services.calibre-web = {
      enable = true;
      listen = {
        ip = "127.0.0.1";
        port = 40508;
      };
      openFirewall = false;
      options = {
        calibreLibrary = builtins.head calibre.libraries;
        enableBookConversion = true;
        enableKepubify = true;
        enableBookUploading = true;
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

    services.nginx.virtualHosts = {
      "library.books.terra.ashwalker.net" = lib.mkIf calibre.enable {
        # enableACME = true;
        # forceSSL = true;
        # listenAddresses = config.services.nginx.publicListenAddresses;
        extraConfig = ''
          client_max_body_size 64M;
        '';
        locations."/" = {
          proxyPass = "http://127.0.0.1:${builtins.toString calibre.port}";
        };
      };
      "books.home.ashwalker.net" = lib.mkIf web.enable {
        enableACME = true;
        forceSSL = true;
        listenAddresses = config.services.nginx.publicListenAddresses;
        extraConfig = ''
          client_max_body_size 64M;
          proxy_connect_timeout 300s;
          proxy_send_timeout 300s;
          proxy_read_timeout 300s;
        '';
        locations."/" = {
          proxyPass = "http://127.0.0.1:${builtins.toString web.listen.port}";
          proxyWebsockets = true;
        };
        locations."~ /(upload|book/add|upload-new)" = {
          proxyPass = "http://127.0.0.1:${builtins.toString web.listen.port}";
          proxyWebsockets = true;
          extraConfig = ''
            client_max_body_size 200m;
          '';
        };
      };
    };
  };
  meta = { };
}
