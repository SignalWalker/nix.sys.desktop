{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  searx = config.services.searx;
in {
  options = with lib; {};
  disabledModules = [];
  imports = lib.signal.fs.path.listFilePaths ./search;
  config = {
    services.searx = {
      enable = false;
      package = pkgs.searxng;
      runInUwsgi = true;
      settings = {
        server = {
          # port = 40524;
          bind_address = "127.0.0.1";
          secret_key = "@SEARX_SECRET_KEY@";
        };
      };
    };
    services.nginx.virtualHosts = lib.mkIf searx.enable {
      "search.home.ashwalker.net" = {
        enableACME = true;
        forceSSL = true;
        listenAddresses = config.services.nginx.publicListenAddresses;
        locations."/" = {
          extraConfig = ''
            uwsgi_pass unix:///run/uwsgi/searx.sock;

            include uwsgi_params;

            uwsgi_param    HTTP_HOST             $host;
            uwsgi_param    HTTP_CONNECTION       $http_connection;

            # see flaskfix.py
            uwsgi_param    HTTP_X_SCHEME         $scheme;
            uwsgi_param    HTTP_X_SCRIPT_NAME    /searxng;

            # see limiter.py
            uwsgi_param    HTTP_X_REAL_IP        $remote_addr;
            uwsgi_param    HTTP_X_FORWARDED_FOR  $proxy_add_x_forwarded_for;
          '';
        };
      };
    };
  };
  meta = {};
}
