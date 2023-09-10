{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  grocy = config.services.grocy-signal;
  php = config.services.phpfpm;
  nginx = config.services.nginx;
in {
  options = with lib; {
    services.grocy-signal = {
      enable = mkEnableOption "grocy";
      user = mkOption {
        type = types.str;
        readOnly = true;
        default = "grocy";
      };
      group = mkOption {
        type = types.str;
        default = "grocy";
      };
      package = mkOption {
        type = types.package;
        default = pkgs.grocy;
      };
      php = {
        pool = mkOption {
          type = types.str;
          default = grocy.user;
        };
        package = mkOption {
          type = types.package;
          default = pkgs.php81;
        };
      };
      dir = {
        state = mkOption {
          type = types.str;
          readOnly = true;
          default = "/var/lib/${grocy.user}";
        };
        configuration = mkOption {
          type = types.str;
          readOnly = true;
          default = "/etc/${grocy.user}";
        };
        cache = mkOption {
          type = types.str;
          readOnly = true;
          default = "/var/cache/${grocy.user}";
        };
      };
      nginx = {
        hostName = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        enableACME = mkEnableOption "ACME";
        forceSSL = mkEnableOption "force SSL";
      };
      settings = {
        currency = mkOption {
          type = types.str;
          default = "USD";
          example = "EUR";
          description = lib.mdDoc ''
            ISO 4217 code for the currency to display.
          '';
        };

        culture = mkOption {
          type = types.enum ["de" "en" "da" "en_GB" "es" "fr" "hu" "it" "nl" "no" "pl" "pt_BR" "ru" "sk_SK" "sv_SE" "tr"];
          default = "en";
          description = lib.mdDoc ''
            Display language of the frontend.
          '';
        };

        calendar = {
          showWeekNumber = mkOption {
            default = true;
            type = types.bool;
            description = lib.mdDoc ''
              Show the number of the weeks in the calendar views.
            '';
          };
          firstDayOfWeek = mkOption {
            default = null;
            type = types.nullOr (types.enum (range 0 6));
            description = lib.mdDoc ''
              Which day of the week (0=Sunday, 1=Monday etc.) should be the
              first day.
            '';
          };
        };
      };
    };
  };
  disabledModules = [];
  imports = [];
  config = lib.mkIf grocy.enable {
    services.grocy.enable = lib.mkForce false;

    users.users.${grocy.user} = {
      isSystemUser = true;
      createHome = true;
      home = grocy.dir.state;
      inherit (grocy) group;
    };
    users.groups.${grocy.group} = {};

    environment.etc."${grocy.user}/config.php".text = ''
      <?php
      Setting('CULTURE', '${grocy.settings.culture}');
      Setting('CURRENCY', '${grocy.settings.currency}');
      Setting('CALENDAR_FIRST_DAY_OF_WEEK', '${toString grocy.settings.calendar.firstDayOfWeek}');
      Setting('CALENDAR_SHOW_WEEK_OF_YEAR', ${std.boolToString grocy.settings.calendar.showWeekNumber});
    '';

    systemd.tmpfiles.rules =
      (map (
        dirName: "d '${grocy.dir.state}/${dirName}' - ${grocy.user} ${grocy.group} - -"
      ) ["viewcache" "plugins" "settingoverrides" "storage"])
      ++ [
        "L+ ${grocy.dir.state}/public - - - - ${grocy.package}/public"
      ];

    services.phpfpm.pools.${grocy.php.pool} = {
      inherit (grocy) user group;
      phpPackage = grocy.php.package;
      phpEnv = {
        GROCY_CONFIG_FILE = "${grocy.dir.configuration}/config.php";
        GROCY_DB_FILE = "${grocy.dir.state}/grocy.db";
        GROCY_STORAGE_DIR = "${grocy.dir.state}/storage";
        GROCY_PLUGIN_DIR = "${grocy.dir.state}/plugins";
        GROCY_CACHE_DIR = "${grocy.dir.state}/viewcache";
      };
      phpOptions = let
        ext = pkgs.php81Extensions;
      in ''
        max_execution_time = 500
        extension = ${ext.fileinfo}/lib/php/extensions/fileinfo.so
        extension = ${ext.pdo_sqlite}/lib/php/extensions/pdo_sqlite.so
        extension = ${ext.gd}/lib/php/extensions/gd.so
        extension = ${ext.ctype}/lib/php/extensions/ctype.so
        extension = ${ext.intl}/lib/php/extensions/intl.so
        extension = ${ext.zlib}/lib/php/extensions/zlib.so
        extension = ${ext.mbstring}/lib/php/extensions/mbstring.so
      '';
      settings = {
        "listen.owner" = config.services.nginx.user;
        "listen.group" = config.services.nginx.group;
        "php_admin_value[error_log]" = "stderr";
        "php_admin_flag[log_errors]" = true;
        "catch_workers_output" = true;
        "pm" = "dynamic";
        "pm.max_children" = "64";
        "pm.start_servers" = "2";
        "pm.min_spare_servers" = "2";
        "pm.max_spare_servers" = "16";
        "pm.max_requests" = "500";
      };
    };

    services.nginx = lib.mkIf (grocy.nginx.hostName != null) {
      enable = true;
      virtualHosts.${grocy.nginx.hostName} = {
        inherit (grocy.nginx) enableACME forceSSL;
        root = "${grocy.dir.state}/public";
        locations."/".extraConfig = ''
          rewrite ^ /index.php;
        '';
        locations."~ \\.php$".extraConfig = ''
          fastcgi_split_path_info ^(.+\.php)(/.+)$;
          fastcgi_pass unix:${php.pools.${grocy.php.pool}.socket};
          include ${nginx.package}/conf/fastcgi.conf;
          include ${nginx.package}/conf/fastcgi_params;
        '';
        locations."~ \\.(js|css|ttf|woff2?|png|jpe?g|svg)$".extraConfig = ''
          add_header Cache-Control "public, max-age=15778463";
          add_header X-Content-Type-Options nosniff;
          add_header X-XSS-Protection "1; mode=block";
          add_header X-Robots-Tag none;
          add_header X-Download-Options noopen;
          add_header X-Permitted-Cross-Domain-Policies none;
          add_header Referrer-Policy no-referrer;
          access_log off;
        '';
        extraConfig = ''
          try_files $uri /index.php$is_args$query_string;
        '';
      };
    };
  };
  meta = {};
}
