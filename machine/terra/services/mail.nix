{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  mail = config.mailserver;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = {
    mailserver = {
      enable = false;
      fqdn = "mail.home.ashwalker.net";
      domains = ["home.ashwalker.net"];
      loginAccounts = {
        "ash@home.ashwalker.net" = {
          hashedPasswordFile = secrets.emailAshPassword.path;
          aliases = ["admin@home.ashwalker.net"];
        };
      };
      certificateScheme = "acme-nginx";
    };
  };
  meta = {};
}
