{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  sessionPkgs = config.services.displayManager.sessionPackages;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = {
    # programs.regreet = {
    #   enable = false;
    # };
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

    services.greetd = let
      greetd = config.services.greetd;
      sessions = {
        wayland =
          std.concatStringsSep ":" (["/usr/share/wayland-sessions"]
            ++ (map (pkg: "${pkg}/share/wayland-sessions") sessionPkgs));
        x11 =
          std.concatStringsSep ":" (["/usr/share/xsessions"]
            ++ (map (pkg: "${pkg}/share/xsessions") sessionPkgs));
      };
    in {
      enable = config.services.desktopManager.manager != "plasma6";
      settings = {
        default_session = {
          user = "greeter";
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --asterisks --remember --remember-session --greeting SignalOS --sessions ${sessions.wayland}:${sessions.x11}";
        };
      };
    };
  };
  meta = {};
}
