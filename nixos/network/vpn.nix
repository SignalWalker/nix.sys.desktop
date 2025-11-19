{
  ...
}:
{
  config = {
    services.mullvad-vpn = {
      enable = false;
    };

    networking.wireguard.networks."wg-signal" = {
      privateKeyFile = "/run/wireguard/wg-signal.sign";
    };

    networking.wireguard.tunnels = {
      "wg-airvpn" = {
        enable = true;
        privateKeyFile = "/run/wireguard/wg-airvpn.sign";
        dns = [
          "10.128.0.1"
          "fd7d:76ee:e68f:a993::1"
        ];
        table = 51820;
        port = 51820;
        priority = 20;
        mtu = 1320;
        peer = {
          publicKey = "PyLCXAQT8KkM4T+dUsOQfn+Ub3pGxfGlxkIApuig+hk=";
          presharedKeyFile = "/run/wireguard/wg-airvpn.psk";
          # airvpn terrebellum
          endpoint = "198.44.136.30:1637";
          allowedIps = [
            "0.0.0.0/0"
            "::/0"
          ];
        };
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
  meta = { };
}
