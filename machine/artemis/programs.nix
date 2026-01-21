{
  ...
}:
{
  options = { };
  disabledModules = [ ];
  imports = [ ];
  config = {
    # NOTE :: must start kdeconnectd in compositor (rn this is handled by a home-manager service)
    programs.kdeconnect = {
      enable = true;
    };

    programs.weylus = {
      enable = true;
      users = [ "ash" ];
      openFirewall = true;
    };
  };
  meta = { };
}
