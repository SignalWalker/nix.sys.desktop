{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = { };
  disabledModules = [ ];
  
  config = {
    services.appflowy = {
      enable = false; # TODO :: write module
    };
  };
  meta = { };
}