{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  st = config.services.syncthing;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = {
    services.syncthing = {
      enable = true;
      user = "ash";
      configDir = "${config.users.users.${st.user}.home}/.config/syncthing";
      # this is called "dataDir" but it's actually the default folder for new sync folders
      dataDir = "${config.users.users.${st.user}.home}/public";
      openDefaultPorts = true; # tcp 22000, udp 21027
    };
  };
  meta = {};
}
