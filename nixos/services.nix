{
  lib,
  ...
}:
{
  imports = lib.listFilePaths ./services;
  config = {
    services.dbus = {
      enable = true;
      implementation = "broker";
    };
    location.provider = "geoclue2";
    services.geoclue2 = {
      enable = true;
    };
  };
  meta = { };
}

