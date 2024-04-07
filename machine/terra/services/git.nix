{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  forgejo = config.services.forgejo;
  domain = "git.home.ashwalker.net";
  secrets = config.age.secrets;
  redis = config.services.redis.servers."forgejo";
in {
  options = with lib; {
  };
  disabledModules = [];
  imports = [];
  config = {
    age.secrets = {
      gitMailerPassword = {
        file = ./git/gitMailerPassword.age;
        owner = forgejo.user;
        group = forgejo.group;
      };
      gitDbPassword = {
        file = ./git/gitDbPassword.age;
        owner = forgejo.user;
        group = forgejo.group;
      };
    };
    services.forgejo = let
      redisUri = "redis+socket://${redis.unixSocket}";
    in {
      enable = true;
      stateDir = "/var/lib/forgejo"; # this is an elysium dataset
      database = {
        type = "postgres";
        name = forgejo.user;
        user = forgejo.user;
        passwordFile = secrets.gitDbPassword.path;
      };
      mailerPasswordFile = secrets.gitMailerPassword.path;
      dump = {
        enable = true;
        type = "tar.zst";
      };
      lfs = {
        enable = true;
      };
      settings = {
        DEFAULT = {
          APP_NAME = "SignalForge";
        };
        session = {
          PROVIDER = "redis";
          PROVIDER_CONFIG = redisUri;
          COOKIE_SECURE = true;
        };
        server = {
          DOMAIN = domain;
          PROTOCOL = "http+unix";
          ROOT_URL = "https://${domain}/";
        };
        cache = lib.mkIf redis.enable {
          ADAPTER = "redis";
          HOST = redisUri;
        };
        security = {
          INSTALL_LOCK = true;
        };
        service = {
          DISABLE_REGISTRATION = true;
        };
        picture = {
          ENABLE_FEDERATED_AVATAR = true;
        };
        federation = {
          ENABLED = true;
        };
      };
    };
    services.redis.servers."forgejo" = {
      enable = true;
      user = forgejo.user;
    };
    services.nginx.virtualHosts.${domain} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://unix:${forgejo.settings.server.HTTP_ADDR}";
        extraConfig = ''
          client_max_body_size 512M;
        '';
      };
    };
  };
  meta = {};
}
