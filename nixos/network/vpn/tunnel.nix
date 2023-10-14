{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  tunnels = config.signal.network.wireguard.tunnels;
in {
  options = with lib; {
    signal.network.wireguard = {
      tunnels = mkOption {
        type = types.attrsOf (types.submoduleWith {
          modules = [
            ({
              config,
              lib,
              pkgs,
              name,
              ...
            }: {
              options = with lib; {
                enable = mkEnableOption "wireguard tunnel :: ${name}";
                port = mkOption {
                  type = types.either types.port (types.enum ["auto"]);
                  example = 51860;
                  default = "auto";
                };
                privateKeyFile = mkOption {
                  type = types.str;
                  description = "runtime path of private key file";
                };
                dns = mkOption {
                  type = types.listOf types.str;
                  default = [];
                };
                addresses = mkOption {
                  type = types.listOf types.str;
                };
                peer = {
                  publicKey = mkOption {
                    type = types.str;
                  };
                  presharedKeyFile = mkOption {
                    type = types.str;
                  };
                  endpoint = mkOption {
                    type = types.str;
                  };
                  allowedIps = mkOption {
                    type = types.listOf types.str;
                  };
                };
                table = mkOption {
                  type = types.int;
                  example = 51820;
                };
                fwMark = mkOption {
                  type = types.int;
                  default = config.table;
                };
                priority = mkOption {
                  type = types.int;
                  example = 10;
                };
                routingPolicyRules = mkOption {
                  type = types.listOf types.anything;
                  default = [
                    {
                      routingPolicyRuleConfig = {
                        FirewallMark = config.fwMark;
                        InvertRule = true;
                        Table = config.table;
                        Priority = config.priority + 1;
                        Family = "both";
                      };
                    }
                    {
                      routingPolicyRuleConfig = {
                        Table = "main";
                        Priority = config.priority;
                        SuppressPrefixLength = 0;
                        Family = "both";
                      };
                    }
                  ];
                };
              };
              config = {};
            })
          ];
        });
      };
    };
  };
  disabledModules = [];
  imports = [];
  config = {
    signal.network.wireguard.networks = std.mapAttrs (tunName: tunnel:
      lib.mkIf tunnel.enable {
        enable = tunnel.enable;
        inherit (tunnel) privateKeyFile dns addresses port;
        firewallMark = tunnel.fwMark;
        routeTable = toString tunnel.table;
        peers = [
          (tunnel.peer
            // {
              persistentKeepAlive = 15;
            })
        ];
        extraNetworkConfig = {
          linkConfig = {
            ActivationPolicy = "manual";
          };
          networkConfig = {
            # DNSDefaultRoute = true;
            Domains = "~.";
          };
          inherit (tunnel) routingPolicyRules;
          routes =
            map (dest: {
              routeConfig = {
                Destination = dest;
                Table = tunnel.table;
                Scope = "link";
              };
            })
            tunnel.peer.allowedIps;
        };
      })
    tunnels;
  };
  meta = {};
}
