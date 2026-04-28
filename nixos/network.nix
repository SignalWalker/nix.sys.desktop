{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = lib.listFilePaths ./network;
  config = {
    programs.wireshark = {
      enable = false; # FIX :: build error 2026-05-03
      package = pkgs.wireshark;
    };

    services.blueman = {
      enable = false; # config.hardware.bluetooth.enable;
    };

    services.resolved = {
      multicastDns = true;
    };

    services.tailscale = {
      tailnet.name = "tail3d611.ts.net";
    };

    networking.networkmanager = {
      enable = lib.mkDefault false; # lib.mkDefault (!config.systemd.network.enable);
    };
  };
  meta = { };
}
