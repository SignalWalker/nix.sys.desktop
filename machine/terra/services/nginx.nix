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
    services.nginx = {
      publicListenAddresses = mkOption {
        description = "Default listen addresses for public virtual hosts.";
        type = types.listOf types.str;
        default = [
          "192.168.0.2"
          "[fd24:fad3:9137::2]"
        ];
      };
    };
  };
  disabledModules = [];
  imports = [];
  config = {
    services.nginx = {
      enable = true;

      recommendedBrotliSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedZstdSettings = true;

      defaultListenAddresses = [
        # by default, listen only on wg-signal and localhost
        "127.0.0.1"
        "[::1]"

        "172.24.86.0"
        "[fd24:fad3:8246::0]"
      ];
    };
    networking.firewall.allowedTCPPorts = [80 443];
  };
  meta = {};
}
