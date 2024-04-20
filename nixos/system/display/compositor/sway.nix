{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  sway = config.programs.sway;

  runSway = pkgs.writeShellScript "run-sway" (readFile ./sway/run-sway.sh);

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
    services.displayManager.sessionPackages = [sway-session];

    programs.sway = {
      enable = true;
      wrapperFeatures = {
        base = true;
        gtk = true;
      };
      extraPackages = with pkgs; [
        swaylock
        # swaylock-effects
        swayidle
      ];
    };
  };
  meta = {};
}
