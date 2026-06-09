{
  ...
}:
{
  options = { };
  disabledModules = [ ];
  # lib.listFilePaths ./security;
  config = {
    security = {
      auditd = {
        enable = true;
      };
    };
    # TODO :: crowdsec
    # services.crowdsec = {
    #   enable = false; # there aren't any bouncers packaged yet.......
    #   settings = {
    #     api.server.trusted_ips = [
    #       "172.24.86.0/24" # wg-signal
    #     ];
    #   };
    #   extraGroups = [
    #     "nginx"
    #   ];
    # };
  };
  meta = { };
}
