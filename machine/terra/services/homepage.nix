{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  domain = "home.terra.ashwalker.net";
  glance = config.services.glance;
in {
  options = with lib; {
    services.glance = {
      monitorSites = mkOption {
        type = types.listOf (types.attrsOf types.anything);
        default = [];
      };
    };
  };
  disabledModules = [];
  imports = [];
  config = {
    # services.homepage-dashboard = {
    #   enable = false;
    #   listenPort = 30801;
    #   openFirewall = lib.mkForce false;
    #   startUrl = "http://${domain}";
    # };

    services.nginx.virtualHosts.${domain} = lib.mkIf glance.enable {
      enableACME = false;
      forceSSL = false;
      locations."/".proxyPass = "http://${glance.settings.host}:${toString glance.settings.port}";
    };
    services.glance = {
      enable = false;
      settings = {
        host = "127.0.0.1";
        port = 58434;
        pages = [
          {
            name = "home";
            columns = [
              {
                size = "small";
                widgets = [
                  {
                    type = "calendar";
                    "first-day-of-week" = "sunday";
                  }
                  {
                    type = "server-stats";
                    servers = [
                      {
                        type = "local";
                        name = "Terra";
                      }
                    ];
                  }
                  {
                    type = "monitor";
                    cache = "12m";
                    title = "Services";
                    style = "compact";
                    sites =
                      [
                        {
                          title = "ashwalker.net";
                          url = "https://ashwalker.net";
                        }
                        {
                          title = "signalgarden.net";
                          url = "https://signalgarden.net";
                        }
                      ]
                      ++ glance.monitorSites;
                  }
                ];
              }
              {
                size = "full";
                widgets = [
                  {
                    type = "group";
                    widgets = [
                      {type = "lobsters";}
                    ];
                  }
                ];
              }
              {
                size = "small";
                widgets = [
                  {
                    type = "weather";
                    location = "Atlanta, United States";
                    units = "metric";
                    "hour-format" = "24h";
                  }
                  {
                    type = "bookmarks";
                    groups = [
                      {
                        title = "Social";
                        "same-tab" = true;
                        links = [
                          {
                            title = "Neocities";
                            url = "https://neocities.org";
                          }
                          {
                            title = "MelonLand";
                            url = "https://forum.melonland.net/";
                          }
                          {
                            title = "FreakScene";
                            url = "https://freakscene.us/";
                          }
                          {
                            title = "Sufficient Velocity";
                            url = "https://forums.sufficientvelocity.com";
                          }
                          {
                            title = "t/suki";
                            url = "https://forum.tsuki.games";
                          }
                        ];
                      }
                    ];
                  }
                ];
              }
            ];
          }
        ];
      };
    };
  };
  meta = {};
}
