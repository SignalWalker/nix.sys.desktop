{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  gnupg = config.programs.gnupg;
  agent = gnupg.agent;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = {
    services.gnome.gnome-keyring = {
      enable = true;
    };

    programs.gnupg = {
      agent = {
        enable = true;
        enableSSHSupport = true;
        enableBrowserSocket = true;
        enableExtraSocket = true;
        pinentryPackage = pkgs.pinentry-qt;
        settings = let
          ttl = 7200; # 2 hours
        in {
          "max-cache-ttl" = ttl;
          "default-cache-ttl" = ttl;
          "max-cache-ttl-ssh" = ttl;
          "default-cache-ttl-ssh" = ttl;
          "allow-preset-passphrase" = true;
        };
      };
      dirmngr = {
        enable = true;
      };
    };

    security.pam.u2f = {
      enable = true;
      settings = {
        cue = true;
      };
      control = "sufficient";
    };

    security.pam.services = {
      login = {
        u2fAuth = true;
        enableGnomeKeyring = config.services.gnome.gnome-keyring.enable;
        gnupg = {
          enable = true;
          noAutostart = true;
        };
      };

      sudo.u2fAuth = true;

      swaylock = {
        u2fAuth = true;
        text = ''
          auth  include login
        '';
      };
    };

    security.pam.loginLimits = [
      {
        domain = "ash";
        item = "nofile";
        type = "hard";
        value = 524288;
      }
      {
        domain = "ash";
        item = "nofile";
        type = "soft";
        value = 524288;
      }
    ];

    security.polkit = {
      enable = true;

      # polkit.addRule(function(action, subject) {
      #   if (
      #     subject.isInGroup("wheel")
      #       && (
      #         action.id == "org.freedesktop.login1.reboot" ||
      #         action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
      #         action.id == "org.freedesktop.login1.power-off" ||
      #         action.id == "org.freedesktop.login1.power-off-multiple-sessions" ||
      #       )
      #     )
      #   {
      #     return polkit.Result.YES;
      #   }
      # });
      extraConfig = ''
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
  };
  meta = {};
}
