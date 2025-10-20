{
  config,
  pkgs,
  lib,
  ...
}:
with builtins;
let
  std = pkgs.lib;
  qbit = config.services.qbittorrent;
in
{
  options = with lib; {
    services.qbittorrent = {
      enable = mkEnableOption "qbittorrent";
      package = mkOption {
        type = types.package;
        default = pkgs.qbittorrent-nox;
      };
      user = mkOption {
        type = types.str;
        default = "qbittorrent";
      };
      group = mkOption {
        type = types.str;
        default = qbit.user;
      };
      configDir = mkOption {
        type = types.str;
        readOnly = true;
        default = "/etc/${qbit.user}";
      };
      dataDir = mkOption {
        type = types.str;
        readOnly = true;
        default = "/var/lib/${qbit.user}";
      };
      webui = {
        port = mkOption {
          type = types.port;
          default = 43256;
        };
        hostName = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
      };
      torrent = {
        port = mkOption {
          type = types.port;
          default = 18698;
        };
      };
    };
  };
  disabledModules = [ "services/torrent/qbittorrent.nix" ];
  imports = [ ];
  config = lib.mkIf qbit.enable {
    users.users.${qbit.user} = {
      isSystemUser = true;
      group = qbit.group;
      home = qbit.dataDir;
    };
    users.groups.${qbit.group} = { };

    networking.firewall.allowedTCPPorts = [ qbit.torrent.port ];
    networking.firewall.allowedUDPPorts = [ qbit.torrent.port ];

    systemd.services.qbittorrent = {
      after = [
        "network-online.target"
        "nss-lookup.target"
        "update-dynamic-ip.service"
      ];
      wants = [
        "network-online.target"
        "update-dynamic-ip.service"
      ];
      description = "QBitTorrent Daemon";
      wantedBy = [ "multi-user.target" ];
      path = [ qbit.package ];
      serviceConfig = {
        ConfigurationDirectory = qbit.user;
        StateDirectory = qbit.user;
        ExecStart = "${qbit.package}/bin/qbittorrent-nox --webui-port=${toString qbit.webui.port} --torrenting-port=${toString qbit.torrent.port}";
        Type = "exec";
        User = qbit.user;
        Group = qbit.group;
        AmbientCapabilities = [ "CAP_NET_RAW" ];
      };
    };

    services.nginx.virtualHosts = lib.mkIf (qbit.webui.hostName != null) {
      ${qbit.webui.hostName} = {
        enableACME = false;
        forceSSL = false;
        addSSL = true;
        sslCertificate = config.services.nginx.terraCert;
        sslCertificateKey = config.services.nginx.terraCertKey;

        # listenAddresses = ["172.24.86.0" "[fd24:fad3:8246::]"];

        locations."/" = {
          extraConfig = ''
            proxy_pass         http://127.0.0.1:${toString qbit.webui.port}/;
            proxy_http_version 1.1;

            proxy_set_header   Host               127.0.0.1:${toString qbit.webui.port};
            proxy_set_header   X-Forwarded-Host   $http_host;
            proxy_set_header   X-Forwarded-For    $remote_addr;

            # not used by qBittorrent
            #proxy_set_header   X-Forwarded-Proto  $scheme;
            #proxy_set_header   X-Real-IP          $remote_addr;

            # optionally, you can adjust the POST request size limit, to allow adding a lot of torrents at once
            client_max_body_size 100M;

            # Since v4.2.2, is possible to configure qBittorrent
            # to set the "Secure" flag for the session cookie automatically.
            # However, that option does nothing unless using qBittorrent's built-in HTTPS functionality.
            # For this use case, where qBittorrent itself is using plain HTTP
            # (and regardless of whether or not the external website uses HTTPS),
            # the flag must be set here, in the proxy configuration itself.
            # Note: If this flag is set while the external website uses only HTTP, this will cause
            # the login mechanism to not work without any apparent errors in console/network resulting in "auth loops".
            proxy_cookie_path  /                  "/; Secure";
          '';
        };
      };
    };
  };
  meta = { };
}
