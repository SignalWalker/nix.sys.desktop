{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  syncthing = config.services.syncthing;
in {
  options = with lib; {
    services.syncthing = {
      gui = {
        port = mkOption {
          type = types.port;
          readOnly = true;
          default = 8384;
        };
      };
    };
  };
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

    services.nginx.virtualHosts."sync.terra.ashwalker.net" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString syncthing.gui.port}/";
        recommendedProxySettings = false;
        extraConfig = ''
          proxy_set_header Host 127.0.0.1:${toString syncthing.gui.port};

          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;


          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
        '';
      };
    };
  };
  meta = {};
}
