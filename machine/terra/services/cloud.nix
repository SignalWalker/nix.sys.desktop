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
  config = lib.mkIf false {
    age.secrets.cloudAdminPassword = {
      file = ./cloud/cloudAdminPassword.age;
      owner = "nextcloud";
      group = "nextcloud";
    };

    services.nextcloud = {
      enable = true;
      hostName = "cloud.home.ashwalker.net";
      https = true;
      package = pkgs.nextcloud28;
      autoUpdateApps.enable = true;
      configureRedis = true;
      database.createLocally = true;
      settings = {
        overwriteprotocol =
          if nc.https
          then "https"
          else null;
        default_phone_region = "US";
      };
      config = {
        dbtype = "pgsql";
        dbuser = "nextcloud";
        dbhost = "/run/postgresql";
        dbname = "nextcloud";
        adminpassFile = config.age.secrets.cloudAdminPassword.path;
        adminuser = "admin";
      };
      phpOptions = {
        # upload_max_filesize = "64G";
        # post_max_size = "64G";
      };
    };

    services.nginx.virtualHosts.${nc.hostName} = {
      enableACME = true;
      forceSSL = true;
      listenAddresses = config.services.nginx.publicListenAddresses;
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
  meta = {};
}
