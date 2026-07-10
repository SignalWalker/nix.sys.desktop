{
  config,
  pkgs,
  lib,
  ...
}:
let
  qbit = config.services.qbittorrent;
in
{
  options =
    let
      inherit (lib) mkEnableOption mkOption types;
    in
    {
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

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString qbit.webui.port}";
        };
      };
    };
  };
  meta = { };
}
