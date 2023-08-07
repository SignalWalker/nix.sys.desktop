{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  airvpn = config.signal.network.wireguard.networks."wg-airvpn";
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = {
    services.mullvad-vpn = {
      enable = true;
    };

    signal.network.wireguard.networks."wg-signal" = {
      privateKeyFile = "/run/wireguard/wg-signal.sign";
    };

    signal.network.wireguard.networks."wg-airvpn" = {
      enable = true;
      privateKeyFile = "/run/wireguard/wg-airvpn.sign";
      dns = ["10.128.0.1" "fd7d:76ee:e68f:a993::1"];
      # routeTable = "1000";
      firewallMark = 34952;
      peers = [
        {
          publicKey = "PyLCXAQT8KkM4T+dUsOQfn+Ub3pGxfGlxkIApuig+hk=";
          presharedKeyFile = "/run/wireguard/wg-airvpn.psk";
          endpoint = "64.42.179.34:1637";
          allowedIps = ["0.0.0.0/0" "::/0"];
          persistentKeepAlive = 15;
        }
      ];
      # TODO :: figure out a good way to keep this out of public repos
      addresses = ["10.171.122.61/32" "fd7d:76ee:e68f:a993:4543:e7b0:c146:840d/128"];
      extraNetworkConfig = {
        linkConfig = {
          ActivationPolicy = "manual";
        };
        networkConfig = {
          DNSDefaultRoute = true;
        };
        routingPolicyRules = [
          {
            routingPolicyRuleConfig = {
              FirewallMark = airvpn.firewallMark;
              InvertRule = true;
              Table = 1000;
              Priority = 10;
              Family = "both";
            };
          }
          # exempt lan addresses
          {
            routingPolicyRuleConfig = {
              To = "192.168.0.0/24";
              Priority = 9;
            };
          }
          {
            routingPolicyRuleConfig = {
              To = "10.0.0.0/24";
              Priority = 9;
            };
          }
        ];
        routes = [
          {
            routeConfig = {
              Gateway = "10.128.0.1";
              GatewayOnLink = true;
              Table = 1000;
            };
          }
        ];
      };
    };
    systemd.tmpfiles.rules = [
      "C /run/wireguard/wg-signal.sign - - - - /home/ash/.local/share/wireguard/wg-signal.sign"
      "z /run/wireguard/wg-signal.sign 0400 systemd-network systemd-network"

      "C /run/wireguard/wg-airvpn.sign - - - - /home/ash/.local/share/wireguard/wg-airvpn.sign"
      "z /run/wireguard/wg-airvpn.sign 0400 systemd-network systemd-network"

      "C /run/wireguard/wg-airvpn.psk - - - - /home/ash/.local/share/wireguard/wg-airvpn.psk"
      "z /run/wireguard/wg-airvpn.psk 0400 systemd-network systemd-network"
    ];
  };
  meta = {};
}
