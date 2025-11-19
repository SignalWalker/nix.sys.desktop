{
  config,
  pkgs,
  lib,
  ...
}:
{
  config =
    let
      couchdb = config.services.couchdb;
    in
    {
      services.couchdb = {
        enable = true;
      };
      services.nginx.virtualHosts."couchdb.home.ashwalker.net" = {
        enableACME = true;
        forceSSL = true;
        listenAddresses = config.services.nginx.publicListenAddresses;
        locations."/" = {
          proxyPass = "http://localhost:${builtins.toString couchdb.port}";
          extraConfig = ''
            proxy_redirect off;
            proxy_buffering off;
          '';
        };
      };
    };
}
