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
  imports = lib.signal.fs.path.listFilePaths ./programs;
  config = {
    # services.guix = {
    #   enable = fa;
    # };
    # users.groups.${config.services.guix.build.group}.members = ["ash"];
  };
  meta = {};
}
