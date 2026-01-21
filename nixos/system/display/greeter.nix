{
  config,
  pkgs,
  lib,
  ...
}:
let
  greetd = config.services.greetd;
  regreet = config.programs.regreet;
  sessionPkgs = config.services.displayManager.sessionPackages;
in
{
  config = {

    #
    # services.displayManager = {
    #   sddm = {
    #     enable = false;
    #     wayland.enable = false;
    #   };
    #   ly = {
    #     enable = false;
    #     settings = {
    #       animation = "colormix";
    #       bigclock = "en";
    #       brightness_up_cmd = "light -A 2";
    #       brightness_down_cmd = "light -U 2";
    #       brightness_up_key = "XF86MonBrightnessUp";
    #       brightness_down_key = "XF86MonBrightnessDown";
    #       clear_password = true;
    #       clock = "%Y-%m-%d %H:%M";
    #     };
    #   };
    # };

    programs.regreet = {
      enable = false;
    };

    services.greetd =
      let
        sessions = {
          wayland = lib.concatStringsSep ":" (
            [ "/usr/share/wayland-sessions" ] ++ (map (pkg: "${pkg}/share/wayland-sessions") sessionPkgs)
          );
          x11 = lib.concatStringsSep ":" (
            [ "/usr/share/xsessions" ] ++ (map (pkg: "${pkg}/share/xsessions") sessionPkgs)
          );
        };
      in
      {
        enable = config.services.desktopManager.manager != "plasma6";
        useTextGreeter = !regreet.enable;
        settings = {
          default_session = {
            user = "greeter";
            command =
              lib.mkIf (!regreet.enable)
                "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --remember --remember-session --greeting SignalOS --sessions ${sessions.wayland}:${sessions.x11}";
          };
        };
      };
  };
  meta = { };
}
