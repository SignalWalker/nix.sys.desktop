{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
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
    systemd.tmpfiles.rules = [
      "C /run/wireguard/wg-signal.sign - - - - /home/ash/.local/share/wireguard/wg-signal.sign"
      "z /run/wireguard/wg-signal.sign 0400 systemd-network systemd-network"
    ];
  };
  meta = {};
}
