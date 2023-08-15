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
                gateway = mkOption {
                  type = types.str;
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
                routingPolicyRules = mkOption {
                  type = types.listOf types.anything;
                  default = [
                    {
                      routingPolicyRuleConfig = {
                        FirewallMark = 51820;
                        InvertRule = true;
                        Table = 51820;
                        Priority = 10;
                        Family = "both";
                      };
                    }
                    {
                      routingPolicyRuleConfig = {
                        Table = "main";
                        Priority = 9;
                        SuppressPrefixLength = 0;
                        Family = "both";
                      };
                    }
                    # exempt local addresses
                    {
                      routingPolicyRuleConfig = {
                        To = "192.168.0.0/24";
                        Priority = 6;
                      };
                    }
                    {
                      routingPolicyRuleConfig = {
                        To = "10.0.0.0/24";
                        Priority = 6;
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
        firewallMark = 51820;
        routeTable = "51820";
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
            DNSDefaultRoute = true;
            Domains = "~.";
          };
          inherit (tunnel) routingPolicyRules;
        };
      })
    tunnels;
  };
  meta = {};
}
