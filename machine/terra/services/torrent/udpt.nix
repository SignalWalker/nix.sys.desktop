{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  udpt = config.services.udpt;
  toml = pkgs.formats.toml {};
in {
  options = with lib; {
    services.udpt = {
      enable = mkEnableOption "udpt torrent tracker";
      package = mkPackageOption pkgs "updt" {};
      user = mkOption {
        type = types.str;
        readOnly = true;
        default = "udpt";
      };
      group = mkOption {
        type = types.str;
        readOnly = true;
        default = "udpt";
      };
      port = mkOption {
        type = types.port;
        default = 42784;
      };
      settings = mkOption {
        type = toml.type;
        default = {};
      };
      settingsFile = mkOption {
        type = types.path;
        readOnly = true;
        default = toml.generate "udpt.toml" udpt.settings;
      };
    };
  };
  disabledModules = [];
  imports = [];
  config = lib.mkIf udpt.enable {
    users.users.${udpt.user} = {
      isSsytemUser = true;
      inherit (udpt) group;
    };
    users.groups.${udpt.group} = {};

    networking.firewall.allowedUDPPorts = [udpt.port];

    systemd.services."udpt" = {
      after = ["network-online.target" "nss-lookup.target"];
      wants = ["network-online.target"];
      # wantedBy = ["multi-user.target"];
      description = "udpt torrent tracker";
      path = [udpt.package];
      serviceConfig = {
        ExecStart = "${udpt.package}/bin/udpt -c ${udpt.configFile}";
        User = udpt.user;
        Group = udpt.group;
      };
    };
  };
  meta = {};
}
