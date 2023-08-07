{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  sunshine = config.services.sunshine;
in {
  options = with lib; {
    services.sunshine = {
      enable = mkEnableOption "sunshine game streaming";
    };
  };
  disabledModules = [];
  imports = [];
  config = lib.mkIf sunshine.enable {
    # systemd.services.sunshine = {
    #
    # };
  };
  meta = {};
}
