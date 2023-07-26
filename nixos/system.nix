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
  imports = lib.signal.fs.path.listFilePaths ./system;
  config = {
    programs.dconf.enable = true;

    services.greetd = let
      greetd = config.services.greetd;
    in {
      enable = true;
      settings = {
        default_session = {
          command =
            if config.programs.regreet.enable
            then "${pkgs.dbus}/bin/dbus-run-session ${lib.getExe pkgs.cage} -s -- ${lib.getExe config.programs.regreet.package}"
            else "${pkgs.greetd.tuigreet}/bin/tuigreet -tr --asterisks --remember-session -g SignalOS";
        };
      };
    };
    services.xserver.displayManager.sessionPackages = let
      writeSession = name: text:
        (pkgs.writeTextFile {
          name = "${name}.desktop";
          text = ''
            [Desktop Entry]
            Name=${name}
            Type=Application
          '';
          destination = "/share/wayland-sessions/${name}.desktop";
        })
        .overrideAttrs (final: prev: {
          passthru =
            (prev.passthru or {})
            // {
              providedSessions = [name];
            };
        });
    in [
      (writeSession "SwayWrapped" ''
        Comment=Sway + features
        Exec=sway-wrapper -d ${
          if config.hardware.nvidia.modesetting.enable
          then "--unsupported-gpu"
          else ""
        } 1> $XDG_CONFIG_HOME/log/sway/out.log 2> $XDG_CONFIG_HOME/log/sway/err.log
      '')
    ];
    programs.regreet = {
      enable = true;
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

    services.resolved = {
      multicastDns = true;
    };

    networking.networkmanager = {
      enable = lib.mkDefault (!config.systemd.network.enable);
      wifi.backend = "iwd";
    };

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };

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
      enable = true;
      useQtScaling = true;
    };
    programs.river = {
      enable = true;
      extraPackages = with pkgs; [
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
        });
        polkit.addRule(function(action, subject) {
          if (
            subject.isInGroup("wheel")
            && (
              action.id == "org.libvirt.unix.manage"
            )
          ) {
            return polkit.Result.YES;
          }
        });
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
      enable = config.hardware.bluetooth.enable;
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

    services.auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "schedutil";
          turbo = "auto";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };
    };

    # services.transmission = {
    #   enable = true;
    #   settings = {
    #   };
    #   openPeerPorts = true;
    #   openRPCPort = true;
    # };
    services.deluge = let
      deluge = config.services.deluge;
    in {
      enable = false; # todo
      # authFile = null; # todo
      declarative = false; # todo
      openFirewall = true;
      config = {
        download_location = "${deluge.dataDir}/downloads";
        share_ratio_limit = "2.0";
        allow_remote = true;
        daemon_port = 58846;
        listen_ports = [6881 6889];
      };
      web = {
        enable = false; # todo
        openFirewall = true;
        port = 8112;
      };
    };

    services.mullvad-vpn = {
      enable = true;
    };

    signal.network.wireguard.networks."wg-signal" = {
      privateKeyFile = "/run/wireguard/wg-signal.sign";
    };
    systemd.tmpfiles.rules = [
      "C /run/wireguard/wg-signal.sign - - - - /home/ash/.local/share/wireguard/wg-signal.sign"
      "z /run/wireguard/wg-signal.sign 0400 systemd-network systemd-network"
    ];

    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark-qt;
    };

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      package = pkgs.steam.override {
        extraEnv = {
          "MANGOHUD" = true;
          "OBS_VKCAPTURE" = true;
        };
        extraPkgs = pkgs:
          with pkgs; [
            mangohud
            gamescope
          ];
      };
    };
  };
  meta = {};
}
