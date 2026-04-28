{
  config,
  pkgs,
  lib,
  ...
}:
let
  secrets = config.age.secrets;
in
{
  config = {
    age.secrets.hetznerDnsApiKey = {
      file = ./secrets/hetznerDnsApiKey.age;
    };
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "admin@ashwalker.net";
      };
      certs = {
        "home.ashwalker.net" = {
          domain = "home.ashwalker.net";
          extraDomainNames = [
            "*.home.ashwalker.net"
          ];
          dnsProvider = "hetzner";
          dnsPropagationCheck = true;
          credentialFiles = {
            "HETZNER_API_KEY_FILE" = secrets.hetznerDnsApiKey.path;
          };
        };
      };
    };
    users.users.nginx.extraGroups = [ "acme" ];
  };
  meta = { };
}
