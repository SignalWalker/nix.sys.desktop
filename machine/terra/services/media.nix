{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = {
    services.jellyfin = {
      enable = true;
      openFirewall = false;
    };

    services.nginx.virtualHosts."media.home.ashwalker.net" = {
      enableACME = true;
      forceSSL = true;

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
        proxyPass = "http://127.0.0.1:8096";
        extraConfig = ''
          proxy_set_header X-Forwarded-Protocol $scheme;
          # Disable buffering when the nginx proxy gets very resource heavy upon streaming
          proxy_buffering off;
        '';
      };

      locations."=/web/" = {
        proxyPass = "http://127.0.0.1:8096/web/index.html";
        extraConfig = ''
          proxy_set_header X-Forwarded-Protocol $scheme;
        '';
      };

      locations."/socket" = {
        proxyPass = "http://127.0.0.1:8096";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header X-Forwarded-Protocol $scheme;
        '';
      };
    };
  };
  meta = {};
}
