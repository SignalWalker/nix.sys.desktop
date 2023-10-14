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
  options = with lib; {
  };
  disabledModules = [];
  imports = lib.signal.fs.path.listFilePaths ./vpn;
  config = {
    services.mullvad-vpn = {
      enable = false;
    };

    signal.network.wireguard.networks."wg-signal" = {
      privateKeyFile = "/run/wireguard/wg-signal.sign";
    };

    signal.network.wireguard.tunnels = {
      "wg-airvpn" = {
        enable = true;
        privateKeyFile = "/run/wireguard/wg-airvpn.sign";
        dns = ["10.128.0.1" "fd7d:76ee:e68f:a993::1"];
        table = 51820;
        priority = 20;
        peer = {
          publicKey = "PyLCXAQT8KkM4T+dUsOQfn+Ub3pGxfGlxkIApuig+hk=";
          presharedKeyFile = "/run/wireguard/wg-airvpn.psk";
          # airvpn musca
          endpoint = "64.42.179.45:1637";
          allowedIps = ["0.0.0.0/0" "::/0"];
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
  meta = {};
}
