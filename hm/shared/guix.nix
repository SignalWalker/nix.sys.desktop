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
  profile = gdirs.profile;
  bin = gdirs.bin;
  channels = guix.channels;
  settings = guix.settings;
in {
  options = with lib; {
    programs.guix = {
      enable = mkEnableOption "GNU Guix";
      directories = {
        configuration = {
          relative = mkOption {
            type = types.str;
            default = "guix";
          };
          absolute = mkOption {
            type = types.str;
            readOnly = true;
            default = "${config.xdg.configHome}/${gdirs.configuration.relative}";
          };
        };
        profile = {
          guix = mkOption {
            type = types.str;
            readOnly = true;
            default = "${gdirs.configuration.absolute}/current";
          };
          packages = mkOption {
            type = types.str;
            default = "${config.home.homeDirectory}/.guix-profile";
          };
        };
        bin = {
          guix = mkOption {
            type = types.str;
            readOnly = true;
            default = "${profile.guix}/bin";
          };
          packages = mkOption {
            type = types.str;
            readOnly = true;
            default = "${profile.packages}/bin";
          };
        };
        locales = mkOption {
          type = types.str;
          readOnly = true;
          default = "${profile.packages}/lib/locale";
        };
      };
      loginInit = mkOption {
        type = types.path;
        readOnly = true;
        default = pkgs.writeText "guix.profile" ''
          source $GUIX_PROFILE/etc/profile
          GUIX_PROFILE_OLD=$GUIX_PROFILE
          export GUIX_PROFILE=${profile.guix}
          source ${profile.guix}/etc/profile
          export GUIX_PROFILE=$GUIX_PROFILE_OLD
          unset GUIX_PROFILE_OLD
          # export GUIX_LOGIN_VARIABLES_INITIALIZED=1
        '';
      };
      channels = {
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
  config = let
    shellInitExtra = ''
      if [[ -z "$GUIX_LOGIN_VARIABLES_INITIALIZED" ]]; then
        source ${guix.loginInit}
      fi
    '';
  in
    lib.mkIf guix.enable {
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
        "GUIX_PROFILE" = profile.packages;
        "GUIX_LOCPATH" = gdirs.locales;
      };
      # home.sessionPath = [gdirs.bin];
      programs.bash.profileExtra = "source ${guix.loginInit}";
      programs.zsh.profileExtra = "source ${guix.loginInit}";
      # programs.bash.initExtra = shellInitExtra;
      # programs.zsh.initExtra = shellInitExtra;
      xdg.configFile = {
        "${gdirs.configuration.relative}/channels.scm".source = channels.file;
        "${gdirs.configuration.relative}/config.scm".source = settings.file;
      };
    };
  meta = {};
}
