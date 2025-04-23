{
  config,
  pkgs,
  lib,
  ...
}:
with builtins;
let
  std = pkgs.lib;
  gnupg = config.programs.gnupg;
  agent = gnupg.agent;
  polkit = config.security.polkit;
in
{
  options = with lib; {
    security.polkit = {
      allowedUserActions = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      allowedUserPrefixes = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      allowedAdminActions = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      allowedAdminPrefixes = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
    };
  };
  disabledModules = [ ];
  imports = [ ];
  config = {
    services.gnome.gnome-keyring = {
      enable = true;
    };

    # WARN :: automatically retrieve unknown keys from keyserver; potential privacy leak
    environment.etc."gnupg/gpg.conf".text = ''
      auto-key-retrieve
      keyserver hkps://keys.openpgp.org
    '';

    programs.gnupg = {
      agent = {
        enable = true;
        enableSSHSupport = true;
        enableBrowserSocket = true;
        enableExtraSocket = true;
        pinentryPackage = pkgs.pinentry-qt;
        settings =
          let
            ttl = 43200; # 12 hours
          in
          {
            "max-cache-ttl" = ttl;
            "default-cache-ttl" = ttl;
            "max-cache-ttl-ssh" = ttl;
            "default-cache-ttl-ssh" = ttl;
            # NOTE :: necessary for pam-gnupg
            "allow-preset-passphrase" = "";
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
      allowedAdminActions = [
        "org.auto-cpufreq.pkexec"
      ];
      allowedAdminPrefixes = [
        "org.libvirt."
        "org.freedesktop.Flatpak."
        "org.freedesktop.network1."
      ];
      allowedUserActions = [
      ];
      allowedUserPrefixes = [
        "org.freedesktop.login1.reboot"
        "org.freedesktop.login1.power-off"
        "org.freedesktop.login1.hibernate"
        "org.freedesktop.login1.suspend"
        "com.feralinteractive.GameMode."
        "org.freedesktop.NetworkManager."
        "org.freedesktop.RealtimeKit1."
      ];
      extraConfig =
        let
          mkActionList = actions: lib.concatStringsSep ", " (map (action: "\"${action}\"") actions);
          mkPrefixList =
            prefixes:
            lib.concatStringsSep " || " (map (prefix: "(action.id.indexOf(\"${prefix}\") == 0)") prefixes);
          userActions = mkActionList polkit.allowedUserActions;
          userPrefixes = mkPrefixList polkit.allowedUserPrefixes;
          adminActions = mkActionList polkit.allowedAdminActions;
          adminPrefixes = mkPrefixList polkit.allowedAdminPrefixes;
        in
        ''
          polkit.addRule(function(action, subject) {
            if (
              subject.isInGroup("wheel")
              && (
                ([
                  ${adminActions}
                ].indexOf(action.id) !== -1)
                || (${adminPrefixes})
              )
            ) {
              return polkit.Result.YES;
            }
          });
          polkit.addRule(function(action, subject) {
            if (
              subject.isInGroup("users")
              && (
                ([
                  ${userActions}
                ].indexOf(action.id) !== -1)
                || (${userPrefixes})
              )
            ) {
              return polkit.Result.YES;
            }
          });
        '';
    };
  };
  meta = { };
}
