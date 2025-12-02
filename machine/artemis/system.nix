{
  ...
}:
{
  config = {
    environment.variables = {
      # LIBMOUNT_DEBUG = "all";
    };
    services.sanoid = {
      datasets = {
        "rpool/nixos/home" = {
          useTemplate = [ "standard" ];
          recursive = true;
        };
        "rpool/nixos/var/lib" = {
          useTemplate = [ "standard" ];
          recursive = true;
        };
        "rpool/media/image" = {
          useTemplate = [ "standard" ];
          recursive = true;
        };
        "rpool/backup" = {
          useTemplate = [ "archive" ];
          recursive = true;
        };
      };
    };

  };
  meta = { };
}
