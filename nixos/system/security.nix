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
