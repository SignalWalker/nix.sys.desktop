{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = {
    programs.dconf.enable = true;

    services.greetd = let
      greetd = config.services.greetd;
    in {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet -tr --asterisks --remember-session -g SignalOS -c 'sway-wrapper -d'";
        };
      };
    };

    systemd.network.enable = false;

    networking.networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;
    };

    programs.sway = {
      enable = true;
      wrapperFeatures = {
        base = true;
        gtk = true;
      };
      extraPackages = with pkgs; [
        swaylock
        swayidle
      ];
    };

    services.dbus.enable = true;

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      wlr.enable = true;
      # extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };

    security.polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (
            subject.isInGroup("wheel")
              && (
                action.id == "org.freedesktop.login1.reboot" ||
                action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
                action.id == "org.freedesktop.login1.power-off" ||
                action.id == "org.freedesktop.login1.power-off-multiple-sessions" ||
              )
            )
          {
            return polkit.Result.YES;
          }
        })
      '';
    };

    programs.light.enable = true;

    services.udisks2 = {
      enable = true;
      settings = {
        "udisks2.conf" = {
        };
        "mount_options.conf" = {
          defaults = {
            btrfs_defaults = "compress=zstd";
          };
        };
      };
    };

    services.blueman = {
      enable = true;
    };

    time.timeZone = "America/New_York";

    home-manager = {
      # useUserPackages = true;
    };
    fonts.fonts = let
      fonts = config.home-manager.users.ash.signal.desktop.theme.font.fonts;
    in
      foldl' (acc: font:
        if (fonts.${font}.package != null)
        then (acc ++ [fonts.${font}.package])
        else acc) [] (attrNames fonts);

    boot.kernelPackages = pkgs.linuxPackages_zen;

    # TODO :: zfs support (this doesn't actually override anything)
    # nixpkgs.config.packageOverrides = pkgs: {
    #   zfs = config.boot.kernelPackages.zfs;
    #   zfsStable = config.boot.kernelPackages.zfsStable;
    #   zfsUnstable = config.boot.kernelPackages.zfsUnstable;
    # };

    security.pam.u2f = {
      enable = true;
      cue = true;
      control = "sufficient";
    };
    security.pam.services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
      swaylock = {
        u2fAuth = true;
        text = ''
          auth  include login
        '';
      };
    };
  };
  meta = {};
}
