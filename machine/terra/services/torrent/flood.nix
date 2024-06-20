{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  flood = config.services.flood-ui;
in {
  options = with lib; {
    services.flood-ui = {
      enable = mkEnableOption "flood bittorrent web ui";
      package = mkPackageOption pkgs "flood" {};
      user = mkOption {
        type = types.str;
        default = "flood";
      };
      group = mkOption {
        type = types.str;
        default = flood.user;
      };
      configDir = mkOption {
        type = types.str;
        readOnly = true;
        default = "/etc/${flood.user}";
      };
      dataDir = mkOption {
        type = types.str;
        readOnly = true;
        default = "/var/lib/${flood.user}";
      };
      port = mkOption {
        type = types.port;
        default = 43257;
      };
      hostName = mkOption {
        type = types.str;
      };
      baseUri = mkOption {
        type = types.str;
        default = "/";
      };
		qbittorrent = {
			enable = mkEnableOption "qbittorrent integration";
			url = mkOption {
				type = types.str;
			};
			user = mkOption {
				type = types.str;
			};
			passwordFile = mkOption {
				type = types.str;
			};
		}
    };
  };
  disabledModules = [];
  imports = [];
  config = lib.mkIf flood.enable {
    users.users.${flood.user} = {
      isSystemUser = true;
      group = flood.group;
      home = flood.dataDir;
    };
    users.groups.${flood.group} = {};

    systemd.services.flood = {
      after = ["network-online.target" "nss-lookup.target"];
      wants = ["network-online.target"];
      description = "Flood Bittorrent UI";
      wantedBy = ["multi-user.target"];
      path = [flood.package];
      serviceConfig = {
        ConfigurationDirectory = flood.user;
        StateDirectory = flood.user;
        Type = "simple";
        KillMode = "process";
        ExecStart = let
          opts = lib.mkMerge [
            {
              rundir = flood.dataDir;
              host = "127.0.0.1";
              port = flood.port;
              baseuri = flood.baseUri;
            }
            (lib.mkIf flood.qbittorrent.enable {
              qburl = flood.qbittorrent.url;
              qbuser = flood.qbittorrent.user;
              qbpass = "$FLOOD_QBITTORRENT_PASSWORD";
            })
            (lib.mkIf flood.deluge.enable {
              dehost = flood.deluge.host;
              deport = flood.deluge.port;
              deuser = flood.deluge.user;
              depass = "$FLOOD_DELUGE_PASSWORD";
            })
          ];
        in
          "${flood.package}/bin/flood" + (std.concatStringsSep " " (map (key: "--${key}=${toString opts.${key}}") (attrNames opts)));
        User = flood.user;
        Group = flood.group;
        Restart = "on-failure";
        RestartSec = 3;
      };
    };
  };
  meta = {};
}
