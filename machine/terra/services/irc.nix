{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  bouncer = config.services.znc;
in {
  options = with lib; {};
  disabledModules = [];
  imports = lib.signal.fs.path.listFilePaths ./irc;
  config = {
    services.irc.bouncer = {
      enable = true;
    };
  };
  meta = {};
}
