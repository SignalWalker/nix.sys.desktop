{
  config,
  pkgs,
  lib,
  ...
}:
with builtins;
let
  std = pkgs.lib;
in
{
  options = with lib; { };
  disabledModules = [ ];
  imports = lib.listFilePaths ./network;
  config = {
    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark-qt;
    };

    services.blueman = {
      enable = config.hardware.bluetooth.enable;
    };

    services.resolved = {
      multicastDns = true;
    };

    services.tailscale = {
      tailnet.name = "tail3d611.ts.net";
    };

    networking.networkmanager = {
      enable = lib.mkDefault (!config.systemd.network.enable);
      wifi.backend = "iwd";
    };
  };
  meta = { };
}