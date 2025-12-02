{
  config,
  pkgs,
  lib,
  ...
}:
let
  std = pkgs.lib;
  nginx = config.services.nginx;
in
{
  options =
    let
      inherit (lib) mkOption types;
    in
    {
      services.nginx = {
        publicListenAddresses = mkOption {
          description = "Default listen addresses for public virtual hosts.";
          type = types.listOf types.str;
          default = [
          ];
        };
        terraCert = mkOption {
          type = types.str;
          readOnly = true;
          default = "/etc/nginx/terra.ashwalker.net.crt";
        };
        terraCertKey = mkOption {
          type = types.str;
          readOnly = true;
          default = "/etc/nginx/terra.ashwalker.net.key";
        };
      };
    };
  disabledModules = [ ];
  imports = [ ];
  config = {

    services.nginx = {
      enable = true;

      # additionalModules = attrValues {
      #   inherit (pkgs.nginxModules)
      #
      #   ;
      # };

      logError = "stderr warn";

      statusPage = false;

      recommendedBrotliSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      publicListenAddresses = [
        "0.0.0.0"
        "[::]"
      ];

      defaultListenAddresses = [
        # by default, listen only on wg-signal and localhost
        "127.0.0.1"
        "[::1]"

        "172.24.86.1"
        "[fd24:fad3:8246::1]"
      ];

      commonHttpConfig =
        let
          logFormatFields = [
            "http_host"
            "server_port"
            "request_uri"
            "remote_addr"
            "http_user_agent"
            "request_method"
            "request_length"
            "status"
            "body_bytes_sent"
            "bytes_sent"
            "msec"
            "server_protocol"
            "ssl_protocol"
            "upstream_response_time"
            "upstream_addr"
            "upstream_connect_time"
          ];
          logFormatStr = std.concatStringsSep ",'\n" (
            map (field: "'\"${field}\":\"\$${field}\"") logFormatFields
          );
        in
        ''
          map $remote_addr $should_log {
            172.24.86.1 0;
            fd24:fad3:8246::1 0;
            default 1;
          }

          log_format logger_json_log escape=json '{'
            ${logFormatStr}'
          '}';

          access_log /var/log/nginx/access.log logger_json_log if=$should_log;
        '';

      # virtualHosts."files.home.ashwalker.net" = {
      #   useACMEHost = "home.ashwalker.net";
      #   forceSSL = true;
      #   listenAddresses = nginx.publicListenAddresses;
      #   locations."/" = {
      #     root = "/var/lib/nginx-files";
      #     basicAuthFile = "/etc/nginx/files.home.ashwalker.net";
      #     extraConfig = ''
      #       autoindex on;
      #     '';
      #   };
      # };
    };
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
  meta = { };
}