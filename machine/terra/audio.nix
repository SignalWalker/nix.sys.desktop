{
  ...
}:
{
  config =
    let
      pulsePort = 61750;
    in
    {
      networking.firewall.allowedLocalTcpPorts = [ pulsePort ];
      services.pipewire = {
        extraConfig = {
          pipewire = {
            # NOTE :: multiple sample rates aren't recommended right now due to issues with bluetooth: https://docs.pipewire.org/page_man_pipewire_conf_5.html
            # so, this is only enabled on Terra, which doesn't currently have bluetooth
            "10-sample-rates" = {
              "context.properties" = {
                "default.clock.allowed-rates" = [
                  44100
                  48000
                ];
              };
            };
          };
          pipewire-pulse = {
            "10-zeroconf-publish" = {
              "pulse.cmd" = [
                {
                  cmd = "load-module";
                  args = "module-native-protocol-tcp port=${toString pulsePort} listen=0.0.0.0";
                }
                {
                  cmd = "load-module";
                  args = "module-zeroconf-publish";
                }
              ];
            };
          };
        };
      };
    };
}
