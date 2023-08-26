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
        "127.0.0.0/24"
        "172.24.86.0/24"
        "fd24:fad3:8246::0/48"
      ];
      zones = std.foldl' (acc: name: let
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
        }) {} (attrNames machines);
    };
    # services.unbound = {
    #   enable = true;
    #   resolveLocalQueries = false;
    #
    # };
  };
  meta = {};
}
