{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  guix = config.programs.guix;
  gdirs = guix.directories;
  rdirs = gdirs.relative;
  channels = guix.channels;
  settings = guix.settings;
in {
  options = with lib; {
    programs.guix = {
      enable = mkEnableOption "GNU Guix";
      directories = {
        relative = {
          config = mkOption {
            type = types.str;
            default = "guix";
          };
        };
        profile = mkOption {
          type = types.str;
          default = "${gdirs.config}/current";
        };
        config = mkOption {
          type = types.str;
          readOnly = true;
          default = "${config.xdg.configHome}/${rdirs.config}";
        };
        bin = mkOption {
          type = types.str;
          readOnly = true;
          default = "${gdirs.profile}/bin";
        };
        locales = mkOption {
          type = types.str;
          readOnly = true;
          default = "${gdirs.profile}/lib/locale";
        };
      };
      channels = {
        path = mkOption {
          type = types.str;
          readOnly = true;
          default = "${gdirs.config}/channels.scm";
        };
        extra = mkOption {
          type = types.lines;
          default = "";
        };
        file = mkOption {
          type = types.path;
          readOnly = true;
          default = pkgs.writeText "channels.scm" channels.extra;
        };
      };
      settings = {
        path = mkOption {
          type = types.str;
          readOnly = true;
          default = "${gdirs.config}/config.scm";
        };
        extra = mkOption {
          type = types.lines;
          default = "";
        };
        file = mkOption {
          type = types.path;
          readOnly = true;
          default = pkgs.writeText "config.scm" settings.extra;
        };
      };
    };
  };
  disabledModules = [];
  imports = [];
  config = lib.mkIf guix.enable {
    programs.guix = {
      channels.extra = ''
        (cons* (channel
                (name 'nonguix)
                (url "https://gitlab.com/nonguix/nonguix")
                ;; signature verification
                (introduction
                  (make-channel-introduction
                    "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
                    (openpgp-fingerprint
                      "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
              %default-channels)
      '';
    };
    systemd.user.sessionVariables = {
      "GUIX_PROFILE" = gdirs.profile;
      "GUIX_LOCPATH" = gdirs.locales;
    };
    # home.sessionPath = [gdirs.bin];
    programs.bash.profileExtra = "source $GUIX_PROFILE/etc/profile";
    programs.zsh.profileExtra = "source $GUIX_PROFILE/etc/profile";
    xdg.configFile = {
      "${rdirs.config}/channels.scm" = {
        source = channels.file;
        target = "${rdirs.config}/channels.scm";
      };
      "${rdirs.config}/config.scm" = {
        source = settings.file;
        target = "${rdirs.config}/config.scm";
      };
    };
  };
  meta = {};
}
