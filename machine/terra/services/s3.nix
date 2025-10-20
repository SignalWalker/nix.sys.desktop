{
  config,
  pkgs,
  lib,
  ...
}:
with builtins;
let
  std = pkgs.lib;
  garage = config.services.garage;
in
{
  options = with lib; {
    services.garage = {
      port = {
        rpc = mkOption {
          type = types.port;
          default = 3901;
        };
      };
    };
  };
  disabledModules = [ ];
  imports = [ ];
  config = {
    age.secrets.garageEnvironment = {
      file = ./s3/garageEnvironment.age;
    };
    services.garage = {
      enable = true;
      package = pkgs.garage_1;
      environmentFile = config.age.secrets.garageEnvironment.path;
      port = {
        rpc = 42341;
      };
      settings = {
        data_dir = "/var/lib/garage/data";
        metadata_dir = "/var/lib/garage/meta";
        db_engine = "sqlite";
        # NOTE :: don't change this; see https://garagehq.deuxfleurs.fr/documentation/reference-manual/configuration/#replication_factor
        replication_factor = 1;
        rpc_bind_addr = "[fd24:fad3:8246::1]:${toString garage.port.rpc}";
        rpc_public_addr = "[fd24:fad3:8246::1]:${toString garage.port.rpc}";

        s3_api = {
          s3_region = "home";
          root_domain = "s3.ashwalker.net";
          api_bind_addr = "/run/garage/s3.sock";
        };

        # s3_web = {
        #   bind_addr = "unix:///run/garage/web.sock";
        # };

        admin = {
          api_bind_addr = "/run/garage/admin.sock";
        };
      };
    };

    systemd.services.garage = {
      serviceConfig = {
        RuntimeDirectory = "garage";
      };
    };

    services.nginx = {
      upstreams = {
        "s3_backend" = {
          servers = {
            "unix:${garage.settings.s3_api.api_bind_addr}" = { };
          };
        };
      };
      virtualHosts = {
        "s3.ashwalker.net" = {
          enableACME = true;
          forceSSL = true;
          listenAddresses = config.services.nginx.publicListenAddresses;
          locations."/" = {
            proxyPass = "http://s3_backend";
            extraConfig = ''
              proxy_max_temp_file_size 0;
            '';
          };
        };
      };
    };
  };
  meta = { };
}
