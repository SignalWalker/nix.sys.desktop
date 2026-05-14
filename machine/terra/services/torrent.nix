{
  config,
  pkgs,
  lib,
  ...
}:
let
  qbit = config.services.qbittorrent;
  deluge = config.services.deluge;
  radarr = config.services.radarr;
  sonarr = config.services.sonarr;
  prowlarr = config.services.prowlarr;

  secrets = config.age.secrets;
in
{
  options =
    let
      inherit (lib) mkOption types;
    in
    {
      services.radarr = {
        port = mkOption {
          type = types.port;
          readOnly = true;
          default = 7878;
        };
      };
      services.lidarr = {
        port = mkOption {
          type = types.port;
          readOnly = true;
          default = 8686;
        };
      };
      services.prowlarr = {
        port = mkOption {
          type = types.port;
          readOnly = true;
          default = 9696;
        };
      };
    };
  disabledModules = [ ];
  imports = lib.listFilePaths ./torrent;
  config = {
    age.secrets = {
      floodSecrets.file = ./torrent/secrets/floodSecrets.age;
    };

    services.qbittorrent = {
      enable = !config.services.deluge.enable;
      webui = {
        hostName = "torrent.terra.ashwalker.net";
      };
    };

    systemd.services."update-dynamic-ip" = {
      after = [
        "network-online.target"
        "nss-lookup.target"
      ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.curl ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart =
          let
            cookiePath = "/elysium/torrent/mam.cookies";
          in
          "${pkgs.curl}/bin/curl -c ${cookiePath} -b ${cookiePath} https://t.myanonamouse.net/json/dynamicSeedbox.php";
        User = qbit.user;
        Group = qbit.group;
      };
    };

    # TODO :: set up bitmagnet

    services.flood-ui = {
      enable = true;
      hostName = qbit.webui.hostName;
      baseUri = "/flood";
      auth = "none";
      qbittorrent = {
        enable = qbit.enable;
        url = "http://${qbit.webui.hostName}";
        user = "ash";
        passwordFile = secrets.floodSecrets.path;
      };
      deluge = {
        enable = deluge.enable;
        passwordFile = secrets.floodSecrets.path;
      };
    };

    services.radarr = {
      enable = true;
      openFirewall = false;
    };

    services.prowlarr = {
      enable = true;
      openFirewall = false;
    };

    terra.network.tunnel.users = [
      qbit.user
    ];

    services.nginx.virtualHosts =
      let
        defaults = {
          addSSL = true;
          sslCertificate = config.services.nginx.terraCert;
          sslCertificateKey = config.services.nginx.terraCertKey;
        };
      in
      lib.mkMerge [
        (lib.mkIf radarr.enable {
          "radarr.${qbit.webui.hostName}" = defaults // {
            # inherit listenAddresses;
            locations."/".proxyPass = "http://127.0.0.1:${toString radarr.port}";
          };
        })
        (lib.mkIf sonarr.enable {
          "sonarr.${qbit.webui.hostName}" = defaults // {
            # inherit listenAddresses;
            locations."/".proxyPass = "http://127.0.0.1:${toString sonarr.port}";
          };
        })
        (lib.mkIf prowlarr.enable {
          "prowlarr.${qbit.webui.hostName}" = defaults // {
            # inherit listenAddresses;
            locations."/".proxyPass = "http://127.0.0.1:${toString prowlarr.port}";
          };
        })
      ];
  };
  meta = { };
}
