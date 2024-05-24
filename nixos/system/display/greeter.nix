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
    programs.regreet = {
      enable = false;
    };

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
      enable = true;
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
