{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  forgejo = config.services.forgejo;
  domain = "git.ashwalker.net";
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
      gitRunnerToken = {
        file = ./git/gitRunnerToken.age;
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
      secrets = {
        mailer.PASSWD = secrets.gitMailerPassword.path;
      };
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
        repository = {
          ENABLE_PUSH_CREATE_USER = true;
          ENABLE_PUSH_CREATE_ORG = true;
        };
        "repository.signing" = {
          INITIAL_COMMIT = "twofa,pubkey";
          WIKI = "twofa,pubkey";
        };
        actions = {
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
      listenAddresses = config.services.nginx.publicListenAddresses;
      locations."/" = {
        proxyPass = "http://unix:${forgejo.settings.server.HTTP_ADDR}";
        extraConfig = ''
          client_max_body_size 512M;
        '';
      };
    };

    services.gitea-actions-runner = {
      package = pkgs.forgejo-actions-runner;
      instances = {
        ${config.networking.hostName} = {
          enable = true;
          name = config.networking.hostName;
          url = "https://${domain}";
          labels = [
            "native:host"
            "rust-latest:docker://rust:latest"
            "ubuntu-latest:docker://gitea/runner-images:ubuntu-latest"
          ];
          tokenFile = secrets.gitRunnerToken.path;
        };
      };
    };
    virtualisation = {
      containers.enable = true;
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings = {
          dns_enabled = true;
          ipv6_enabled = true;
        };
      };
    };
  };
  meta = {};
}
