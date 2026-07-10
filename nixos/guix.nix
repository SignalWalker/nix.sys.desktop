{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = { };
  disabledModules = [ ];
  imports = [ ];
  config = {
    environment.persistence.${config.system.persist.defaultMount}.directories = [
      "/etc/guix"
      "/var/guix"
      "/gnu"
    ];
    services.guix = {
      enable = true;
      extraArgs = [
        "--discover=yes"
      ];
      substituters = {
        urls = [
          "https://bordeaux.guix.gnu.org"
          "https://ci.guix.gnu.org"
          "https://substitutes.nonguix.org"
        ];
      };
      gc = {
        enable = true;
      };
      publish = {
        enable = true;
        port = 40340;
        extraArgs = [
          "--advertise"
          "--compression=zstd:3"
        ];
      };
    };
  };
  meta = { };
}
