{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  nc = config.services.nextcloud;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = {
    age.secrets.cloudAdminPassword = {
      file = ./cloud/cloudAdminPassword.age;
      owner = "nextcloud";
      group = "nextcloud";
    };

    services.nextcloud = {
      enable = true;
      hostName = "cloud.${config.networking.fqdn}";
      https = true;
      package = pkgs.nextcloud27;
      autoUpdateApps.enable = true;
      config = {
        dbtype = "pgsql";
        dbuser = "nextcloud";
        dbhost = "/run/postgresql";
        dbname = "nextcloud";
        adminpassFile = config.age.secrets.cloudAdminPassword.path;
        adminuser = "admin";
        overwriteProtocol =
          if nc.https
          then "https"
          else null;
      };
    };

    services.nginx.virtualHosts.${nc.hostName} = {
      enableACME = true;
      forceSSL = true;
    };

    services.postgresql = {
      ensureDatabases = [nc.config.dbname];
      ensureUsers = [
        {
          name = nc.config.dbuser;
          ensurePermissions."DATABASE ${nc.config.dbname}" = "ALL PRIVILEGES";
        }
      ];
    };

    systemd.services."nextcloud-setup" = {
      requires = ["postgresql.service"];
      after = ["postgresql.service"];
    };
  };
  meta = {};
}
