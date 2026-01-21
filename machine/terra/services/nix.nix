{
  config,
  lib,
  ...
}:
let
  secrets = config.age.secrets;
  serve = config.services.nix-serve;

  pubkey = "nix-cache.home.ashwalker.net:nfUY5yBAH5M1oCqkW+FjdZa+olzErfDvx6OIXut4THs=";
in
{
  options =
    let
      inherit (lib) mkOption types;
    in
    {
      services.nix-serve = {
        user = mkOption {
          type = types.str;
          readOnly = true;
          default = "nix-serve";
        };
        group = mkOption {
          type = types.str;
          readOnly = true;
          default = "nix-serve";
        };
      };
    };
  config = {
    age.secrets = {
      nixStoreKey = {
        file = ./nix/nixStoreKey.age;
        # owner = serve.user;
        # group = serve.group;
      };
      nixStoreKeyHttp = {
        file = ./nix/nixStoreKeyHttp.age;
        owner = serve.user;
        group = serve.group;
      };
    };
    nix = {
      settings = {
        secret-key-files = [
          secrets.nixStoreKey.path
          secrets.nixStoreKeyHttp.path
        ];
        allowed-users = [ serve.user ];
      };
    };
    services.nix-serve = {
      enable = false; # FIX :: build failure 2026-01-19
      secretKeyFile = secrets.nixStoreKeyHttp.path;
      port = 42533;
    };
    users.users.${serve.user} = {
      isSystemUser = true;
      inherit (serve) group;
    };
    users.groups.${serve.group} = { };
    services.nginx.virtualHosts."nix-cache.home.ashwalker.net" = {
      useACMEHost = "home.ashwalker.net";
      forceSSL = true;
      listenAddresses = config.services.nginx.publicListenAddresses;
      # addSSL = true;
      # sslCertificate = config.services.nginx.terraCert;
      # sslCertificateKey = config.services.nginx.terraCertKey;
      locations."=/public-key" = {
        return = "200 '${pubkey}'";
      };
      locations."=/disko-install-cmd" =
        let
          artemis = "github:signalwalker/nix.sys.desktop#artemis";
          diskoInstall = "github:nix-community/disko/latest#disko-install";
          substituters = lib.concatStringsSep " " (
            [ "https://nix-cache.home.ashwalker.net" ] ++ config.nix.settings.substituters
          );
          pubkeys = lib.concatStringsSep " " ([ pubkey ] ++ config.nix.settings.trusted-public-keys);
          cmd = "nix --extra-experimental-features \"nix-command flakes\" run \"${diskoInstall}\" -- --option substituters \"${substituters}\" --option trusted-public-keys \"${pubkeys}\" --flake \"${artemis}\" --disk main /dev/nvme0n1";
        in
        {
          return = "200 '${cmd}'";
        };
      locations."/" = {
        proxyPass = "http://${serve.bindAddress}:${toString serve.port}";
      };
    };

    # services.glance.monitorSites = [
    #   {
    #     title = "Nix Cache";
    #     url = "http://nix-cache.terra.ashwalker.net";
    #   }
    # ];
  };
  meta = { };
}
