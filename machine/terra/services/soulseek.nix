{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  soul = config.services.slskd;
in {
  # options = with lib; {
  #   services.slskd = {
  #     user = mkOption {
  #       type = types.str;
  #       readOnly = true;
  #       default = "slskd";
  #     };
  #     group = mkOption {
  #       type = types.str;
  #       readOnly = true;
  #       default = "slskd";
  #     };
  #     dir = {
  #       state = mkOption {
  #         type = types.str;
  #         readOnly = true;
  #         default = "/var/lib/${soul.user}";
  #       };
  #       cache = mkOption {
  #         type = types.str;
  #         readOnly = true;
  #         default = "/var/cache/${soul.user}";
  #       };
  #     };
  #   };
  # };
  # disabledModules = [];
  # imports = [];
  # config = {
  #   services.slskd = {
  #     openFirewall = true;
  #     nginx.enable = false;
  #     rotateLogs = true;
  #     environmentFile = "";
  #     settings = {
  #       soulseek = {
  #         username = "TheiaPriscilla";
  #         listen_port = 57945;
  #         distributed_network = {
  #           disable_children = true;
  #         };
  #       };
  #       web = {
  #         port = 41807;
  #         url_base = "/";
  #         https = {
  #           port = 41808;
  #         };
  #       };
  #       shares = {
  #         directories = ["[Music]/elysium/media/audio/library"];
  #       };
  #       directories = {
  #         incomplete = "/elysium/media/audio/soulseek/incomplete";
  #         downloads = "/elysium/media/audio/soulseek/downloads";
  #       };
  #       global = {
  #         upload = {
  #           slots = 3;
  #           speed_limit = 512;
  #         };
  #         download = {
  #           slots = 3;
  #         };
  #       };
  #       rooms = [];
  #     };
  #   };
  #   services.nginx.virtualHosts."soulseek.terra.ashwalker.net" = {
  #     forceSSL = true;
  #     locations."/" = {
  #       proxyPass = "http://127.0.0.1:${toString soul.settings.web.port}";
  #       proxyWebsockets = true;
  #     };
  #   };
  # };
  # meta = {};
}
