{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = { };
  disabledModules = [ ];
  imports = [ ];
  config = {
    services.appflowy = {
      enable = false; # TODO :: write module
    };
  };
  meta = { };
}
