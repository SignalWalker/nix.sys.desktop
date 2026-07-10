{
  config,
  pkgs,
  lib,
  ...
}:
let
  sessionPkgs = config.services.displayManager.sessionPackages;
in
{
  config = {

    services.displayManager.noctalia-greeter = {
      enable = true;
      passwordlessSyncUsers = [ "ash" ];
      settings = {
        appearance = {
          hide_logo = true;
          wallpaper = {
            path = "/home/ash/pictures/wallpapers/animated/boat.gif";
            fill_mode = "crop";
          };
        };
        idle = {
          timeout = 600;
        };
        output = {
          name = "Dell Inc. DELL U2415 CFV9N73Q0HAS";
          layout = "Dell Inc. DELL U2415 CFV9N73Q0HAS:0,0; Dell Inc. DELL U2415 CFV9N7AJ21LS:-1200,-390";
          transforms = "Dell Inc. DELL U2415 CFV9N73Q0HAS:0; Dell Inc. DELL U2415 CFV9N7AJ21LS:270";
        };
      };
    };
  };
  meta = { };
}
