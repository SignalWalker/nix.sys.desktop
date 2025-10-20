{
  config,
  pkgs,
  lib,
  ...
}:
with builtins;
let
  std = pkgs.lib;
  nginx = config.services.nginx;
  # bouncer = config.services.znc;
  hostName = "bouncer.irc.terra.ashwalker.net";
  soju = config.services.soju;
in
{
  options = with lib; { };
  disabledModules = [ ];
  imports = [ ]; # lib.listFilePaths ./irc;
  config = {
    users.users.soju = {
      group = "soju";
      description = "IRC bouncer daemon";
      isSystemUser = true;
      home = "/var/lib/soju";
      createHome = false;
    };
    users.groups.soju = {
      members = [ "nginx" ];
    };

    users.users.ash.packages =
      let
        sjAlias =
          alias: name:
          pkgs.writeScriptBin alias ''
            exec sudo -u soju ${soju.package}/bin/${name} -config ${soju.configFile} "$@"
          '';
      in
      [
        (sjAlias "sojudb" "sojudb")

        (sjAlias "sojuctl" "sojuctl")

        (sjAlias "soju-znc-import" "znc-import")

        (sjAlias "soju-migrate-db" "migrate-db")

        (sjAlias "soju-migrate-logs" "migrate-db")
      ];

    services.soju = {
      enable = true;
      # listen = [ "unix:///run/soju/irc.sock" ];
      listen = [
        "172.24.86.1:6667"
        "[fd24:fad3:8246::1]:6667"
        "http+unix:///run/soju/http.sock"
      ];
      tlsCertificate = "/var/lib/soju/terra.ashwalker.net.crt";
      tlsCertificateKey = "/var/lib/soju/terra.ashwalker.net.key";
      acceptProxyIP = [ "localhost" ];
      # inherit hostName;
      hostName = "bouncer.irc.terra.ashwalker.net";
    };

    systemd.services."soju".serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "soju";
      Group = "soju";
    };

    # services.nginx.virtualHosts.${soju.hostName} = {
    #   addSSL = true;
    #   sslCertificate = nginx.terraCert;
    #   sslCertificateKey = nginx.terraCertKey;
    #   locations."/socket" = {
    #     proxyPass = "http://unix:/run/soju/http.sock:/socket";
    #   };
    #   locations."/uploads" = {
    #     proxyPass = "http://unix:/run/soju/http.sock:/uploads";
    #   };
    #   root = pkgs.gamja;
    #   # listen = map (addr: {
    #   #   inherit addr;
    #   #   proxyProtocol = true;
    #   #   port = 1667;
    #   # }) nginx.defaultListenAddresses;
    #   # locations."/" = {
    #   #   proxyPass = "unix:/run/soju/irc.sock";
    #   # };
    # };
  };
  meta = { };
}

