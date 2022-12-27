{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  guix = config.programs.guix;
in {
  options = with lib; {
    programs.guix = {
      enable = mkEnableOption "GNU Guix";
      directories = {
        profile = mkOption {
          type = types.str;
          default = "${config.xdg.configHome}/guix/current";
        };
        bin = mkOption {
          type = types.str;
          readOnly = true;
          default = "${guix.directories.profile}/bin";
        };
      };
    };
  };
  disabledModules = [];
  imports = [];
  config = lib.mkIf guix.enable {
    systemd.user.sessionVariables."GUIX_PROFILE" = guix.directories.profile;
    home.sessionVariables."GUIX_PROFILE" = guix.directories.profile;
    home.sessionPath = [guix.directories.bin];
    # programs.bash.profileExtra = "source $GUIX_PROFILE/etc/profile";
    # programs.zsh.profileExtra = "source $GUIX_PROFILE/etc/profile";
  };
  meta = {};
}
