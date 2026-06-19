{
  ...
}:
{
  config =
    let
      rtpPort = 54865;
    in
    {
      security.rtkit.enable = true;
      networking.firewall.allowedLocalUdpPorts = [
        rtpPort
        # RAOP
        6001
        6002
      ];
      services.pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
        jack.enable = true;
        wireplumber.enable = true;
        raopOpenFirewall = false; # NOTE :: manually allowing these ports using allowedLocalUdpPorts
        extraConfig = {
          pipewire = {
            # WARN :: don't add a multiple-sample-rate conf here, because there's already one for terra

            "10-zeroconf-discover" = {
              "context.modules" = [
                {
                  name = "libpipewire-module-zeroconf-discover";
                  args = {
                    "pulse.latency" = 2000;
                  };
                }
              ];
            };
            "10-airplay-discover" = {
              "context.modules" = [
                {
                  name = "libpipewire-module-raop-discover";
                }
              ];
            };

            # TODO :: find out how to use rtp-session (there's basically no documentation)

            # "10-rtp-session" = {
            #   "context.modules" = [
            #     {
            #       name = "libpipewire-module-rtp-session";
            #       args = {
            #         "sess.name" = "Local RTP Stream";
            #         "sess.media" = "audio";
            #         "sess.latency.msec" = 1000;
            #         "control.port" = rtpPort;
            #         "stream.props" = {
            #           "audio.rate" = 44100; # most of my music files seem to be 44.1khz
            #           "audio.channels" = 2;
            #           "audio.position" = [
            #             "FL"
            #             "FR"
            #           ];
            #         };
            #       };
            #     }
            #   ];
            # };
          };
        };
      };
    };
  meta = { };
}
