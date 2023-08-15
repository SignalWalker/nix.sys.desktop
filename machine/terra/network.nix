{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
in {
  options = with lib; {
    terra.network.tunnel = {
      # enable = (mkEnableOption "tunnel") // {default = true;};
      users = mkOption {
        type = types.listOf types.str;
        default = [];
      };
    };
  };
  disabledModules = [];
  imports = [];
  config = {
    networking.firewall = {
      allowedTCPPorts = [
        9995 # hammerwatch
      ];
      allowedUDPPorts = [
        9995 # hammerwatch
      ];
    };

    signal.network.wireguard.tunnels."wg-airvpn" = {
      # TODO :: figure out a good way to keep this out of public repos
      addresses = ["10.159.66.94/32" "fd7d:76ee:e68f:a993:b560:c12b:27ba:5557/128"];
      routingPolicyRules = foldl' (acc: user:
        acc
        ++ [
          {
            routingPolicyRuleConfig = {
              User = user;
              Table = 51820;
              Priority = 10;
              Family = "both";
            };
          }
          {
            routingPolicyRuleConfig = {
              Table = "main";
              User = user;
              Priority = 9;
              SuppressPrefixLength = 0;
              Family = "both";
            };
          }
          # exempt local addresses
          {
            routingPolicyRuleConfig = {
              To = "192.168.0.0/24";
              User = user;
              Priority = 6;
            };
          }
          {
            routingPolicyRuleConfig = {
              To = "10.0.0.0/24";
              User = user;
              Priority = 6;
            };
          }
          {
            routingPolicyRuleConfig = {
              To = "127.0.0.0/8";
              User = user;
              Priority = 6;
            };
          }
          # {
          #   routingPolicyRuleConfig = {
          #     To = "172.24.86.0/24";
          #     User = user;
          #     Priority = 6;
          #   };
          # }
          # {
          #   routingPolicyRuleConfig = {
          #     To = "fd24:fad3:8246::/48";
          #     User = user;
          #     Priority = 6;
          #   };
          # }
        ]) []
      config.terra.network.tunnel.users;
    };

    services.fail2ban = {
      enable = false;
      maxretry = 6;
      ignoreIP = [
        "127.0.0.0/8"
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
        "::1"
      ];
      bantime = "12m";
      bantime-increment = {
        enable = true;
        rndtime = "8m";
        overalljails = true;
      };
      banaction = "nftables[type=multiport,blocktype=drop]";
      banaction-allports = "nftables[type=allports,blocktype=drop]";
      jails = {
        "nginx-botsearch" = ''
          enabled = true
        '';
      };
    };
  };
  meta = {};
}
