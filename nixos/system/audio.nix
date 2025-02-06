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
      # extraConfig = {
      #   pipewire = {
      #     "92-low-latency" = {
      #       "context.properties" = {
      #
      #       };
      #     };
      #   };
      # };
    };
  };
  meta = {};
}
