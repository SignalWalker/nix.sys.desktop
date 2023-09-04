{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  crowdsec = config.services.crowdsec;
in {
  options = with lib; {};
  disabledModules = [];
  imports = lib.signal.fs.path.listFilePaths ./security;
  config = {
    services.crowdsec = {
      enable = true;
    };
  };
  meta = {};
}
