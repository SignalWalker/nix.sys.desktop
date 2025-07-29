{
  config,
  pkgs,
  lib,
  ...
}:
with builtins;
{
  options = with lib; { };
  disabledModules = [ ];
  imports = [ ];
  config = {
    services.rsyslogd = {
      enable = true;
      extraConfig = ''
        module(load="imtcp")
        input(type="imtcp" port="514")
        action(type="imtcp" file="/var/log/network")

        module(load="imudp")
        input(type="imudp" port="514")
        action(type="imudp" file="/var/log/network")
      '';
    };
  };
  meta = { };
}
