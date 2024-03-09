{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  xserver = config.services.xserver;

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
  in (writeSession "SwayWrapped" (let
    swayCmd = "systemd-cat --identifier=sway --priority=info --stderr-priority=err sway";
  in ''
    DesktopNames=sway
    Comment=Sway with extra features
    TryExec=sway
    Exec=${./display/compositor/sway/run-sway.sh}
  ''));
in {
  options = with lib; {};
  disabledModules = [];
  imports = lib.signal.fs.path.listFilePaths ./display;
  config = {
    programs.dconf.enable = true;

    services.xserver.enable = lib.mkDefault false;

    services.xserver.displayManager.sddm = {
      enable = xserver.enable;
    };

    services.xserver.displayManager.sessionPackages = [sway-session];

    services.greetd = let
      greetd = config.services.greetd;
      sessions = {
        wayland = std.concatStringsSep ":" ["/usr/share/wayland-sessions" "${sway-session}/share/wayland-sessions"];
        x11 = std.concatStringsSep ":" ["/usr/share/xsessions"];
      };
    in {
      enable = !xserver.displayManager.sddm.enable;
      settings = {
        default_session = {
          command =
            if config.programs.regreet.enable
            then "${pkgs.dbus}/bin/dbus-run-session ${lib.getExe pkgs.cage} -s -- ${lib.getExe config.programs.regreet.package}"
            else "${pkgs.greetd.tuigreet}/bin/tuigreet --time --asterisks --remember --remember-session --greeting SignalOS --sessions ${sessions.wayland}";
          user = "greeter";
        };
      };
    };

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
      wlr.enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
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
