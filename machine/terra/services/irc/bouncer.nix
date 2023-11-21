{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  bouncer = config.services.irc.bouncer;
  znc = config.services.znc;
in {
  options = with lib; {
    services.irc.bouncer = {
      enable = mkEnableOption "irc bouncer";
      user = mkOption {
        type = types.str;
        default = "ircbouncer";
      };
      group = mkOption {
        type = types.str;
        default = "ircbouncer";
      };
      dir = {
        state = mkOption {
          type = types.str;
          readOnly = true;
          default = "/var/lib/${bouncer.user}";
        };
        cache = mkOption {
          type = types.str;
          readOnly = true;
          default = "/var/cache/${bouncer.user}";
        };
      };
      port = {
        irc = mkOption {
          type = types.port;
          default = 46667;
        };
      };
    };
  };
  disabledModules = [];
  imports = [];
  config = lib.mkIf bouncer.enable {
    users.users.${bouncer.user} = {
      inherit (bouncer) group;
      description = "IRC bouncer daemon";
      isSystemUser = true;
      home = bouncer.dir.state;
      createHome = true;
    };
    users.groups.${bouncer.group} = {};

    services.znc = {
      enable = true;
      inherit (bouncer) user group;
      dataDir = bouncer.dir.state;
      useLegacyConfig = false;
      # don't need to open it since we're only listening on wg-signal, on which all ports are already open
      openFirewall = false;

      # WARNING: edits to the config from here won't apply unless you delete znc.conf from the server first
      mutable = true;
      config = {
        User."ash" = {
          Admin = true;
          # TODO :: is it really safe to store this here...?
          Pass.password = {
            Method = "sha256";
            Hash = "d276a6a5cca4d198b2aff0fa4c713436ae7b96ee5fd9bc09d0a91f40658b2038";
            Salt = "w8ca7chgIp2!RtOO/?dX";
          };
        };
        Listener = {
          l = {
            AllowIRC = true;
            AllowWeb = true;
            IPv4 = true;
            IPv6 = true;
            Port = bouncer.port.irc;
            SSL = true;
            Host = "172.24.86.1";
          };
        };
      };
    };
  };
  meta = {};
}
