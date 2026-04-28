{
  config,
  pkgs,
  lib,
  ...
}:
let
  surf = config.services.websurfx;
in
{
  options = {
    # services.websurfx = {
    #   enable = mkEnableOption "websurfx search engine";
    #   package = mkPackageOption pkgs "websurfx" { };
    # };
  };
  disabledModules = [ ];
  imports = [ ];
  config = {
  };
  meta = { };
}
