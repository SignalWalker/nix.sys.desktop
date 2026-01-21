{
  config,
  lib,
  ...
}:
let
  playground = config.services.minecraft.servers.playground;
  # driftingLeague = config.services.minecraft.servers.driftingLeague;
  hostName = "minecraft.home.ashwalker.net";
in
{
  config = {
    services.minecraft.servers = {
      # driftingLeague = {
      #   enable = false;
      #   java.memory = {
      #     initial = "1024M";
      #     max = "8912M";
      #   };
      #   packwiz.hostName = hostName;
      #   openFirewall = true;
      #   prism.name = "DriftingLeague";
      # };
      playground = {
        enable = true;
        java.memory = {
          initial = "1024M";
          max = "8912M";
        };
        packwiz.hostName = hostName;
        openFirewall = true;
        prism.name = "Playground";
      };
    };
    services.nginx.virtualHosts = lib.mkIf (playground.enable) {
      ${hostName} = {
        listenAddresses = config.services.nginx.publicListenAddresses;
        useACMEHost = "home.ashwalker.net";
        addSSL = true;
      };
    };
  };
  meta = { };
}
