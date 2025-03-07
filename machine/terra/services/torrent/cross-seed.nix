{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  seed = config.services.cross-seed;
in {
  # options = with lib; {
  #   services.cross-seed = {
  #     enable = mkEnableOption "cross-seed";
  #     package = mkOption {
  #       type = types.package;
  #       default = pkgs.cross-seed;
  #     };
  #     user = mkOption {
  #       type = types.str;
  #       default = "cross-seed";
  #     };
  #     group = mkOption {
  #       type = types.str;
  #       default = "cross-seed";
  #     };
  #     port = mkOption {
  #       type = types.port;
  #       default = 2468;
  #     };
  #     dataDir = mkOption {
  #       type = types.str;
  #       readOnly = true;
  #       default = "/var/lib/${seed.user}";
  #     };
  #   };
  # };
  # disabledModules = [];
  # imports = [];
  # config = lib.mkIf seed.enable (lib.mkMerge [
  #   {
  #     users.users.${seed.user} = {
  #       isSystemUser = true;
  #       home = "/var/lib/${seed.user}";
  #       group = seed.group;
  #     };
  #     users.groups.${seed.group} = {};
  #
  #     systemd.services."cross-seed" = {
  #       after = ["network.target"];
  #       wantedBy = ["multi-user.target"];
  #       path = [pkgs.python311Packages.python];
  #       environment = {
  #         CONFIG_DIR = seed.dataDir;
  #       };
  #       serviceConfig = {
  #         Restart = "always";
  #         RestartSec = 5;
  #         Type = "simple";
  #         User = seed.user;
  #         Group = seed.group;
  #         WorkingDirectory = seed.dataDir;
  #         StateDirectory = seed.user;
  #         StateDirectoryMode = "0750";
  #         ExecStart = "${seed.package}/bin/cross-seed daemon --port ${toString seed.port}";
  #       };
  #     };
  #   }
  # ]);
  # meta = {};
}
