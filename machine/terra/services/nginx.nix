{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  nginx = config.services.nginx;
  mkRobotsTxt = robots: let
    agents = std.concatStringsSep "\n" (map (agent: "User-agent: ${agent}") robots);
  in
    pkgs.writeText "robots.txt" ''
      ${agents}
      Disallow: /
    '';
in {
  options = with lib; {
    services.nginx = {
      publicListenAddresses = mkOption {
        description = "Default listen addresses for public virtual hosts.";
        type = types.listOf types.str;
        default = [
        ];
      };
      agentBlockList = mkOption {
        type = types.listOf types.str;
        default = [];
      };
      robotsTxt = mkOption {
        type = types.package;
        readOnly = true;
        default = mkRobotsTxt nginx.agentBlockList;
      };
      virtualHosts = mkOption {
        type = types.attrsOf (types.submodule {
          config = {
            locations."=/robots.txt" = lib.mkDefault {
              alias = nginx.robotsTxt;
            };
            extraConfig = let
              agentRules = std.concatStringsSep "|" nginx.agentBlockList;
            in ''
              if ($http_user_agent ~* "(${agentRules})") {
                # return 307 https://ash-speed.hetzner.com/10GB.bin;
                return 444; # drop connection
              }
            '';
          };
        });
      };
    };
  };
  disabledModules = [];
  imports = [];
  config = {
    services.nginx = {
      enable = true;

      logError = "stderr warn";

      statusPage = true;

      recommendedBrotliSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedZstdSettings = true;

      publicListenAddresses = [
        "192.168.0.2"
        "[fd24:fad3:9137::2]"
      ];

      defaultListenAddresses = [
        # by default, listen only on wg-signal and localhost
        "127.0.0.1"
        "[::1]"

        "172.24.86.1"
        "[fd24:fad3:8246::1]"
      ];

      commonHttpConfig = let
        agentRules = std.concatStringsSep "|" nginx.agentBlockList;
        logFormatFields = [
          "http_host"
          "status"
          "remote_addr"
          "request_uri"
          "http_user_agent"
          "body_bytes_sent"
          "bytes_sent"
          "msec"
          "request_length"
          "request_method"
          "server_port"
          "server_protocol"
          "ssl_protocol"
          "upstream_response_time"
          "upstream_addr"
          "upstream_connect_time"
        ];
        logFormatStr = std.concatStringsSep ",'\n" (map (field: "'\"${field}\":\"\$${field}\"") logFormatFields);
      in ''
        map $status $not_caught_by_agent_list {
          444 0;
          default 1;
        }
        map $not_caught_by_agent_list$remote_addr $should_log {
          ~^0 0;
          1172.24.86.1 0;
          1fd24:fad3:8246::1 0;
          default 1;
        }

        log_format logger_json_log escape=json '{'
          ${logFormatStr}'
        '}';

        access_log /var/log/nginx/access.log logger_json_log if=$should_log;
      '';

      # TODO :: generate automatically from https://github.com/ai-robots-txt/ai.robots.txt/blob/main/robots.txt
      agentBlockList = [
        "SemrushBot"
        "facebookexternalhit"
        "facebookcatalog"
        "meta-externalagent"
        "meta-externalfetcher"
        "DotBot"
        # from the above repo:
        "Amazonbot"
        "anthropic-ai"
        "Applebot-Extended"
        "Bytespider"
        "CCBot"
        "ChatGPT-User"
        "ClaudeBot"
        "Claude-Web"
        "cohere-ai"
        "Diffbot"
        "FacebookBot"
        "FriendlyCrawler"
        "Google-Extended"
        "GoogleOther"
        "GoogleOther-Image"
        "GoogleOther-Video"
        "GPTBot"
        "ImagesiftBot"
        "img2dataset"
        "omgili"
        "omgilibot"
        "PerplexityBot"
        "YouBot"
      ];
    };
    networking.firewall.allowedTCPPorts = [80 443];
  };
  meta = {};
}
