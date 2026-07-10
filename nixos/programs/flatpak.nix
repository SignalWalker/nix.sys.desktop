{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = let
    env = config.environment;
    defaultMnt = env.defaultPersistMountpoint;
  in {
    services.flatpak = {
      enable = true;
    };
    environment.persistence = {
      ${defaultMnt} = {
        directories = [
          "/var/lib/flatpak"
        ];
      };
    };
  };
  meta = {};
}
