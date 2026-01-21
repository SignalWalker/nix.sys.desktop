{
  config,
  lib,
  ...
}:
{
  options =
    let
      inherit (lib) mkOption types;
    in
    {
      terra.network.tunnel = {
        # enable = (mkEnableOption "tunnel") // {default = true;};
        users = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };
      };
    };
  disabledModules = [ ];
  imports = [ ];
  config = {
    networking.wireless.iwd.enable = false;

    systemd.network.networks = {
      "eth" = {
        ipv6AcceptRAConfig = {
          Token = "prefixstable";
        };
      };
    };

    networking.wireguard.tunnels = {
      "wg-airvpn" = {
        addresses = [
          "10.156.31.29/32"
          "fd7d:76ee:e68f:a993:95cf:4056:9fb6:dc5a/128"
        ];
      };
      "wg-torrent" =
        let
          table = 51821;
        in
        {
          enable = true;
          # FIX :: figure out a good way to keep this out of public repos
          addresses = [
            "10.159.66.94/32"
            "fd7d:76ee:e68f:a993:b560:c12b:27ba:5557/128"
          ];
          privateKeyFile = "/run/wireguard/wg-torrent.sign";
          dns = [
            "10.128.0.1"
            "fd7d:76ee:e68f:a993::1"
          ];
          inherit table;
          port = table;
          peer = {
            publicKey = "PyLCXAQT8KkM4T+dUsOQfn+Ub3pGxfGlxkIApuig+hk=";
            presharedKeyFile = "/run/wireguard/wg-torrent.psk";
            # TODO :: automatically switch between set of endpoints?
            endpoint = "198.44.136.30:1637";
            allowedIps = [
              "0.0.0.0/0"
              "::/0"
            ];
          };
          activationPolicy = "up";
          routingPolicyRules = builtins.foldl' (
            acc: user:
            acc
            ++ [
              {
                User = user;
                Table = table;
                Priority = 10;
                Family = "both";
              }
              {
                Table = "main";
                User = user;
                Priority = 9;
                SuppressPrefixLength = 0;
                Family = "both";
              }
              # exempt local addresses
              {
                To = "192.168.0.0/16";
                User = user;
                Priority = 6;
              }
              # {
              #   routingPolicyRuleConfig = {
              #     To = "10.0.0.0/24";
              #     User = user;
              #     Priority = 6;
              #   };
              # }
              {
                To = "127.0.0.0/8";
                User = user;
                Priority = 6;
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
            ]
          ) [ ] config.terra.network.tunnel.users;
        };
    };

    systemd.tmpfiles.settings = {
      "10-wg-torrent" = {
        "/run/wireguard/wg-torrent.sign" = {
          "C" = {
            argument = "/home/ash/.local/share/wireguard/wg-torrent.sign";
          };
          "z" = {
            mode = "0400";
            user = "systemd-network";
            group = "systemd-network";
          };
        };
        "/run/wireguard/wg-torrent.psk" = {
          "C" = {
            argument = "/home/ash/.local/share/wireguard/wg-torrent.psk";
          };
          "z" = {
            mode = "0400";
            user = "systemd-network";
            group = "systemd-network";
          };
        };
      };
    };

    services.fail2ban = {
      enable = true;
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
  meta = { };
}
