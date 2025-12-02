{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  foundry = config.services.foundryvtt;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = {
    services.foundryvtt = {
      enable = false;
      minifyStaticFiles = true;
      upnp = false;
    };
    services.nginx.virtualHosts = lib.mkIf foundry.enable {
      "vtt.home.ashwalker.net" = {
        useACMEHost = "home.ashwalker.net";
        forceSSL = true;
        listenAddresses = config.services.nginx.publicListenAddresses;
        extraConfig = ''
          client_max_body_size 300M;
        '';
        locations."/" = {
          extraConfig = ''
            # Set proxy headers
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            # These are important to support WebSockets
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "Upgrade";

            # Make sure to set your Foundry VTT port number
            proxy_pass http://localhost:30000;
          '';
        };
      };
    };
  };
  meta = {};
}