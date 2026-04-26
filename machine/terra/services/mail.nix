{
  config,
  ...
}:
let
  secrets = config.age.secrets;
  mail = config.mailserver;
in
{
  config = {
    # mailserver = {
    #   enable = false;
    #   fqdn = "mail.home.ashwalker.net";
    #   domains = [ "home.ashwalker.net" ];
    #   loginAccounts = {
    #     "ash@home.ashwalker.net" = {
    #       hashedPasswordFile = secrets.emailAshPassword.path;
    #       aliases = [ "admin@home.ashwalker.net" ];
    #     };
    #   };
    #   certificateScheme = "acme-nginx";
    # };
  };
  meta = { };
}
