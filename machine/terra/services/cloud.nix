{
  config,
  pkgs,
  lib,
  ...
}:
let
  nc = config.services.nextcloud;
in
{
  config = {
    age.secrets = lib.mkIf nc.enable {
      cloudAdminPassword = {
        file = ./cloud/cloudAdminPassword.age;
        owner = "nextcloud";
        group = "nextcloud";
      };
    };

    services.nextcloud = {
      enable = false;
      hostName = "cloud.home.ashwalker.net";
      https = true;
      package = pkgs.nextcloud35;
      autoUpdateApps.enable = true;
      configureRedis = true;
      database.createLocally = true;
      settings = {
        overwriteprotocol = "https";
        default_phone_region = "US";
      };
      config = {
        dbtype = "pgsql";
        dbuser = "nextcloud";
        dbhost = "/run/postgresql";
        dbname = "nextcloud";
        # adminpassFile = config.age.secrets.cloudAdminPassword.path;
        # adminuser = "admin";
      };
    };

    services.nginx.virtualHosts = lib.mkIf nc.enable {
      ${nc.hostName} = {
        useACMEHost = "home.ashwalker.net";
        forceSSL = true;
        listenAddresses = config.services.nginx.publicListenAddresses;
      };
    };

    # services.postgresql = {
    #   ensureDatabases = [nc.config.dbname];
    #   ensureUsers = [
    #     {
    #       name = nc.config.dbuser;
    #       ensurePermissions."DATABASE ${nc.config.dbname}" = "ALL PRIVILEGES";
    #     }
    #   ];
    # };

    # systemd.services."nextcloud-setup" = {
    #   requires = ["postgresql.service"];
    #   after = ["postgresql.service"];
    # };
  };
}
