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
  imports = lib.signal.fs.path.listFilePaths ./network;
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

    networking.networkmanager = {
      enable = lib.mkDefault (!config.systemd.network.enable);
      wifi.backend = "iwd";
    };
  };
  meta = {};
}
