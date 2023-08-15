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
    services.bind = {
      enable = true;
      cacheNetworks = [
        "127.0.0.0/24"
        "172.24.86.0/24"
        "fd24:fad3:8246::0/48"
      ];
      zones = {
        # "home.ashwalker.net" = {
        #   master = true;
        #   file = ''
        #     $ORIGIN home.ashwalker.net.
        #     $TTL 2h
        #
        #
        #   '';
        # };
        "terra.ashwalker.net" = {
          master = true;
          # @ SOA hydrogen.ns.hetzner.com. dns.hetzner.com. 2023072400 86400 10800 3600000 3600
          file = pkgs.writeText "terra.ashwalker.net.zone" ''
            $ORIGIN terra.ashwalker.net.
            $TTL 2h

            @ IN SOA ns1.terra.ashwalker.net. dns.terra.ashwalker.net. 2023081200 86400 10800 3600000 3600

            @ IN NS ns1.terra.ashwalker.net.

            @ IN A 172.24.86.1
            @ IN AAAA fd24:fad3:8246::1
            * IN A 172.24.86.1
            * IN AAAA fd24:fad3:8246::1
          '';
        };
      };
    };
    # services.unbound = {
    #   enable = true;
    #   resolveLocalQueries = false;
    #
    # };
  };
  meta = {};
}
