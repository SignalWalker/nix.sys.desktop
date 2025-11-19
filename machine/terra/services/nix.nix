{
  config,
  lib,
  ...
}:
with builtins;
let
  secrets = config.age.secrets;
  serve = config.services.nix-serve;
in
{
  options = with lib; {
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
  disabledModules = [ ];
  imports = [ ];
  config = {
    age.secrets.nixStoreKey = {
      file = ./nix/nixStoreKey.age;
      # owner = serve.user;
      # group = serve.group;
    };
    nix = {
      settings = {
        secret-key-files = [ secrets.nixStoreKey.path ];
        # allowed-users = [ serve.user ];
      };
    };
    # services.nix-serve = {
    #   enable = true;
    #   secretKeyFile = secrets.nixStoreKey.path;
    #   port = 42533;
    # };
    # users.users.${serve.user} = {
    #   isSystemUser = true;
    #   inherit (serve) group;
    # };
    # users.groups.${serve.group} = { };
    # services.nginx.virtualHosts."nix-cache.terra.ashwalker.net" = {
    #   addSSL = true;
    #   sslCertificate = config.services.nginx.terraCert;
    #   sslCertificateKey = config.services.nginx.terraCertKey;
    #   locations."/" = {
    #     proxyPass = "http://${serve.bindAddress}:${toString serve.port}";
    #   };
    # };

    # services.glance.monitorSites = [
    #   {
    #     title = "Nix Cache";
    #     url = "http://nix-cache.terra.ashwalker.net";
    #   }
    # ];
  };
  meta = { };
}
