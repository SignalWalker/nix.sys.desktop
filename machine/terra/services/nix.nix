{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  secrets = config.age.secrets;

  pubkey = "nix-cache.home.ashwalker.net:nfUY5yBAH5M1oCqkW+FjdZa+olzErfDvx6OIXut4THs=";

  harmonia = config.services.harmonia;
in
{
  options =
    let
      inherit (lib) mkOption types;
    in
    {
      services.harmonia = {
        user = mkOption {
          type = types.str;
          readOnly = true;
          default = "harmonia";
        };
        group = mkOption {
          type = types.str;
          readOnly = true;
          default = "harmonia";
        };
      };
    };
  imports = [
  ];
  config = {
    age.secrets = {
      nixStoreKey = {
        file = ./nix/nixStoreKey.age;
        owner = harmonia.user;
        group = harmonia.group;
      };
      nixStoreKeyHttp = {
        file = ./nix/nixStoreKeyHttp.age;
        owner = harmonia.user;
        group = harmonia.group;
      };
    };
    nix = {
      settings = {
        secret-key-files = [
          secrets.nixStoreKey.path
          secrets.nixStoreKeyHttp.path
        ];
        allowed-users = [ harmonia.user ];
      };
    };
    services.harmonia = {
      cache = {
        enable = true;
        signKeyPaths = [
          secrets.nixStoreKey.path
          secrets.nixStoreKeyHttp.path
        ];
        settings = {
          bind = "unix:/run/harmonia/socket";
        };
      };
    };

    users.users.${harmonia.user} = {
      isSystemUser = true;
      inherit (harmonia) group;
    };
    users.groups.${harmonia.group} = { };

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
        proxyPass = "http://${harmonia.cache.settings.bind}";
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
