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
    virtualisation.docker = {
      enable = false;
    };
    users.extraGroups.docker.members = ["ash"];
  };
  meta = {};
}
