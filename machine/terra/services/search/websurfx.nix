{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  surf = config.services.websurfx;
in {
  options = with lib; {
    services.websurfx = {
      enable = mkEnableOption "websurfx search engine";
      package = mkPackageOption pkgs "websurfx" {};
    };
  };
  disabledModules = [];
  imports = [];
  config =
    lib.mkIf surf.enable {
    };
  meta = {};
}
