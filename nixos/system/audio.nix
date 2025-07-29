{
  config,
  pkgs,
  lib,
  ...
}:
with builtins;
let
  std = pkgs.lib;
in
{
  options = with lib; { };
  disabledModules = [ ];
  imports = [ ];
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
      # raopOpenFirewall = true;
      # extraconfig = {
      #   pipewire = {
      #     "10-airplay" = {
      #       "context.modules" = [
      #         {
      #           name = "libpipewire-module-raop-discover";
      #         }
      #       ];
      #     };
      #   };
      # };
    };
  };
  meta = { };
}
