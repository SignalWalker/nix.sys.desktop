{
  config,
  pkgs,
  lib,
  ...
}:
{
  options =
    let
      inherit (lib) mkOption types;
    in
    {
      networking.firewall = {
        allowedLocalTcpPorts = mkOption {
          type = types.listOf types.port;
          default = [ ];
        };
        allowedLocalUdpPorts = mkOption {
          type = types.listOf types.port;
          default = [ ];
        };
      };
    };
  disabledModules = [ ];
  imports = [ ];
  config = {
    networking.firewall.extraInputRules =
      let
        ip = lib.concatStringsSep ", " [
          "192.168.0.0/16"
          "172.16.0.0/12"
          "10.0.0.0/8"
        ];
        ip6 = lib.concatStringsSep ", " [
          "fc00::/7"
          "fe80::/10"
        ];
        tcp = config.networking.firewall.allowedLocalTcpPorts;
        udp = config.networking.firewall.allowedLocalUdpPorts;
        tcpStr = lib.concatMapStringsSep ", " (builtins.toString) tcp;
        udpStr = lib.concatMapStringsSep ", " (builtins.toString) udp;
      in
      lib.concatStringsSep "\n" [
        (
          if tcp == [ ] then
            ""
          else
            ''
              ip saddr { ${ip} } tcp dport { ${tcpStr} } accept comment "accepted local tcp"
              ip6 saddr { ${ip6} } tcp dport { ${tcpStr} } accept comment "accepted local tcp"
            ''
        )
        (
          if udp == [ ] then
            ""
          else
            ''
              ip saddr { ${ip} } udp dport { ${udpStr} } accept comment "accepted local udp"
              ip6 saddr { ${ip6} } udp dport { ${udpStr} } accept comment "accepted local udp"
            ''
        )
      ];
  };
  meta = { };
}
