{
  config,
  pkgs,
  lib,
  ...
}:
let
  jelly = config.services.jellyfin;
in
{
  options =
    let
      inherit (lib) mkOption types;
    in
    {
      services.jellyfin = {
        port = mkOption {
          type = types.port;
          readOnly = true;
          default = 8096;
        };
        mdnsPort = mkOption {
          type = types.port;
          readOnly = true;
          default = 7359;
        };
      };
    };
  config = {
    services.jellyfin = {
      enable = true;
      package = pkgs.jellyfin;
      openFirewall = false;
    };

    networking.firewall = {
      allowedLocalUdpPorts = [ jelly.mdnsPort ];
      allowedLocalTcpPorts = [ jelly.port ];
    };

    # services.anubis.instances."jellyfin" = {
    #   target = "http://${navi.listen.address}:${toString navi.listen.port}";
    #   systemd.socketActivated = true;
    #   domain = domain;
    #   env = {
    #     SOCKET_MODE = "0777"; # FIX :: does this really need to be 0777
    #   };
    # };

    services.nginx.virtualHosts."media.home.ashwalker.net" = {
      useACMEHost = "home.ashwalker.net";
      forceSSL = true;

      listenAddresses = config.services.nginx.publicListenAddresses;

      extraConfig = ''
        client_max_body_size 300M;

        add_header X-Frame-Options "SAMEORIGIN";
        # add_header X-XSS-Protection "0"; # Do NOT enable. This is obsolete/dangerous
        add_header X-Content-Type-Options "nosniff";

        add_header Cross-Origin-Opener-Policy "same-origin" always;
        add_header Cross-Origin-Embedder-Policy "require-corp" always;
        add_header Cross-Origin-Resource-Policy "same-origin" always;

        add_header Permissions-Policy "accelerometer=(), ambient-light-sensor=(), battery=(), bluetooth=(), camera=(), clipboard-read=(), display-capture=(), document-domain=(), encrypted-media=(), gamepad=(), geolocation=(), gyroscope=(), hid=(), idle-detection=(), interest-cohort=(), keyboard-map=(), local-fonts=(), magnetometer=(), microphone=(), payment=(), publickey-credentials-get=(), serial=(), sync-xhr=(), usb=(), xr-spatial-tracking=()" always;

        add_header Origin-Agent-Cluster "?1" always;
      '';

      locations."=/" = {
        return = "302 https://$host/web/";
      };

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString jelly.port}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header X-Forwarded-Protocol $scheme;
          # Disable buffering when the nginx proxy gets very resource heavy upon streaming
          proxy_buffering off;
        '';
      };

      locations."=/web/" = {
        proxyPass = "http://127.0.0.1:${toString jelly.port}/web/index.html";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header X-Forwarded-Protocol $scheme;
        '';
      };

      locations."/socket" = {
        proxyPass = "http://127.0.0.1:${toString jelly.port}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header X-Forwarded-Protocol $scheme;
        '';
      };
    };

    services.glance.monitorSites = [
      {
        title = "Jellyfin";
        url = "https://media.home.ashwalker.net";
      }
    ];
  };
  meta = { };
}

