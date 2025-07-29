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
    programs.ydotool = {
      enable = true;
      group = "ydotool";
    };
    users.extraGroups.${config.programs.ydotool.group}.members = [ "ash" ];
  };
  meta = { };
}
