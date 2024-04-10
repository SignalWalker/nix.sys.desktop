{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  machines = config.signal.machines;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = {
    services.bind = {
      enable = true;
      cacheNetworks = [
        # host
        "127.0.0.0/8"

        # private networks
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
        "fc00::/7"
      ];
      forwarders = [
        "9.9.9.9"
        "149.112.112.112"
        "2620:fe::fe"
        "2620:fe::9"
      ];
      zones = foldl' (acc: name: let
        hostName = "${name}.ashwalker.net";
        machine = machines.${name};
      in
        std.recursiveUpdate acc {
          ${hostName} = {
            master = true;
            file = let
              entries = let
                recs = {
                  "v4" = "A";
                  "v6" = "AAAA";
                };
              in
                std.concatLines (std.foldl' (acc: addr: let
                  record = recs.${addr.type};
                in
                  acc
                  ++ [
                    "@ IN ${record} ${addr.address}"
                    "* IN ${record} ${addr.address}"
                  ]) []
                machine.wireguard.addresses);
            in
              pkgs.writeText "${hostName}.zone" ''
                $ORIGIN ${hostName}.
                $TTL 2h

                @ IN SOA ns1.terra.ashwalker.net. dns.terra.ashwalker.net. 2023081200 86400 10800 3600000 3600

                @ IN NS ns1.terra.ashwalker.net.

                ${entries}
              '';
          };
        }) {
        # "home.ashwalker.net" = {
        #   master = true;
        #   file = pkgs.writeText "home.ashwalker.net.zone" ''
        #     $ORIGIN home.ashwalker.net.
        #     $TTL 2h
        #
        #     @ IN SOA ns1.terra.ashwalker.net. dns.terra.ashwalker.net. 2023081200 86400 10800 3600000 3600
        #
        #     @ IN NS ns1.terra.ashwalker.net.
        #
        #     @ IN A 172.24.86.1
        #     * IN A 172.24.86.1
        #     @ IN AAAA fd24:fad3:8246::1
        #     * IN AAAA fd24:fad3:8246::1
        #   '';
        # };
      } (attrNames machines);
    };
    # services.unbound = {
    #   enable = true;
    #   resolveLocalQueries = false;
    #
    # };
  };
  meta = {};
}
