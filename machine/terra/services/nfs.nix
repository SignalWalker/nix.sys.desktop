{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = {
    services.nfs = {
      server = {
        enable = true;
        hostName = "172.24.86.1";
      };
    };
  };
}

