{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;

  runSway = pkgs.writeShellScript "run-sway" (readFile ./display/compositor/sway/run-sway.sh);

  sway-session = let
    writeSession = name: text:
      (pkgs.writeTextFile {
        name = "${name}.desktop";
        text = ''
          [Desktop Entry]
          Version=1.0
          Name=${name}
          Type=Application
          ${text}
        '';
        destination = "/share/wayland-sessions/${name}.desktop";
      })
      // {
        providedSessions = [name];
      };
  in (writeSession "SwayWrapped" ''
    DesktopNames=sway
    Comment=Sway with extra features
    TryExec=sway
    Exec=${runSway}
  '');
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = {
    services.xserver.displayManager.sessionPackages = [sway-session];
    services.greetd = let
      greetd = config.services.greetd;
      sessions = {
        wayland = std.concatStringsSep ":" ["/usr/share/wayland-sessions" "${sway-session}/share/wayland-sessions"];
        x11 = std.concatStringsSep ":" ["/usr/share/xsessions"];
      };
    in {
      enable = true;
      settings = {
        default_session = {
          user = "greeter";
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --asterisks --remember --remember-session --greeting SignalOS --sessions ${sessions.wayland}";
        };
      };
    };
  };
  meta = {};
}
