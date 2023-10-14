{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  xserver = config.services.xserver;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = {
    programs.dconf.enable = true;

    services.xserver.enable = lib.mkDefault false;

    services.xserver.displayManager.sddm = {
      enable = xserver.enable;
    };
    services.greetd = let
      greetd = config.services.greetd;
    in {
      enable = !xserver.displayManager.sddm.enable;
      settings = {
        default_session = {
          command = let
            swayCmd = "sway-wrapper ${
              if config.hardware.nvidia.modesetting.enable
              then "--unsupported-gpu"
              else ""
            } 1> \${XDG_STATE_HOME}/log/sway/out.log 2> \${XDG_STATE_HOME}/log/sway/err.log";
          in
            if config.programs.regreet.enable
            then "${pkgs.dbus}/bin/dbus-run-session ${lib.getExe pkgs.cage} -s -- ${lib.getExe config.programs.regreet.package}"
            else "${pkgs.greetd.tuigreet}/bin/tuigreet -tr --asterisks --remember-session -g SignalOS -c \"${swayCmd}\"";
        };
      };
    };

    environment.systemPackages = let
      writeSession = name: text: let
        fileName = lib.toLower name;
      in
        (pkgs.writeTextFile {
          name = "${fileName}.desktop";
          text = ''
            [Desktop Entry]
            Name=${name}
            Type=Application
            ${text}
          '';
          destination = "/share/wayland-sessions/${fileName}.desktop";
        })
        .overrideAttrs (final: prev: {
          passthru =
            (prev.passthru or {})
            // {
              providedSessions = [fileName];
            };
        });
    in [
      (writeSession "SwayWrapped" ''
        Comment=Sway with extra features
        Exec=sway-wrapper -d ${
          if config.hardware.nvidia.modesetting.enable
          then "--unsupported-gpu"
          else ""
        } 1> $XDG_CONFIG_HOME/log/sway/out.log 2> $XDG_CONFIG_HOME/log/sway/err.log
      '')
    ];
    programs.regreet = {
      enable = false;
      settings = {
        background = {
          path = "/home/ash/pictures/wallpapers/train_and_lake.png";
          fit = "Cover";
        };
        GTK = {
          application_prefer_dark_theme = true;
          cursor_theme_name = "Adwaita";
          font_name = "Cantarell 16";
          icon_theme_name = "Adwaita";
          theme_name = "Adwaita";
        };
        commands = {
          reboot = ["systemctl" "reboot"];
          poweroff = ["systemctl" "poweroff"];
        };
      };
    };
    programs.light.enable = true;
    programs.sway = {
      enable = true;
      wrapperFeatures = {
        base = true;
        gtk = true;
      };
      extraPackages = with pkgs; [
        # swaylock-effects
        swayidle
      ];
    };
    services.xserver.windowManager.qtile = {
      enable = false; # pywlroots build failure
      backend = "wayland";
      extraPackages = python3Packages: [
        python3Packages.qtile-extras
      ];
    };
    services.xserver.desktopManager.plasma5 = {
      enable = xserver.enable;
      useQtScaling = true;
    };

    services.xserver.desktopManager.cinnamon = {
      enable = false;
    };
    services.cinnamon.apps.enable = xserver.desktopManager.cinnamon.enable;

    programs.river = {
      enable = true;
      extraPackages = with pkgs; [
        swayidle
      ];
    };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      wlr.enable = !xserver.enable;
      # extraPortals = lib.mkIf (!xserver.enable) [pkgs.xdg-desktop-portal-gtk];
    };

    fonts.packages = let
      fonts = config.home-manager.users.ash.signal.desktop.theme.font.fonts;
    in
      foldl' (acc: font:
        if (fonts.${font}.package != null)
        then (acc ++ [fonts.${font}.package])
        else acc) [] (attrNames fonts);
  };
  meta = {};
}
