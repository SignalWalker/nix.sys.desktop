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
      enable = true;
      package = pkgs.wireshark-qt;
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
