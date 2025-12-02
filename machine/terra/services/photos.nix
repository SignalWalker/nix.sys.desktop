{
  config,
  ...
}:
let
  immich = config.services.immich;
  domain = "photos.home.ashwalker.net";
in
{
  config = {
    services.immich = {
      enable = true;
      machine-learning = {
        enable = true;
        environment = {
          "MACHINE_LEARNING_DEVICE_IDS" = "0";
          "MACHINE_LEARNING_ANN_FP16_TURBO" = "True";
          "MPLCONFIGDIR" = "/var/cache/immich/matplotlib";
        };
      };
      host = "0.0.0.0";
      database = {
        enable = true;
        enableVectors = false; # obselete
        enableVectorChord = true;
      };
      accelerationDevices = null; # allows all
      mediaLocation = "/elysium/media/video/photos";
      settings = {
        server = {
          externalDomain = "https://${domain}";
        };
        storageTemplate = {
          enabled = true;
          template = "{{y}}/{{y}}-{{MM}}-{{dd}}/{{filename}}";
        };
        ffmpeg = {
          transcode = "disabled";
          acceptedVideoCodecs = [
            "h264"
            "hevc"
            "vp9"
            "av1"
          ];
          acceptedContainers = [
            "ogg"
            "webm"
          ];
          targetVideoCodec = "av1";
          targetAudioCodec = "libopus";
          targetResolution = "1080";
          preset = "fast";
        };
        image = {
          extractEmbedded = true;
          fullsize = {
            enabled = true;
            format = "webp";
          };
          preview = {
            format = "webp";
          };
        };
        machineLearning = {
          enabled = immich.machine-learning.enable;
          facialRecognition = {
            enabled = true;
          };
          ocr = {
            enabled = false;
          };
          clip = {
            enabled = true; # NOTE :: required for duplicate detection
            modelName = "ViT-SO400M-16-SigLIP2-384__webli";
          };
        };
      };
    };

    # hardware-accelerated transcoding
    users.users.immich.extraGroups = [
      "video"
      "render"
    ];

    networking.firewall = {
      allowedLocalTcpPorts = [ immich.port ];
    };

    services.nginx.virtualHosts.${domain} = {
      useACMEHost = "home.ashwalker.net";
      forceSSL = true;
      listenAddresses = config.services.nginx.publicListenAddresses;
      locations."/" = {
        proxyPass = "http://0.0.0.0:${builtins.toString immich.port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
        extraConfig = ''
          client_max_body_size 50000M;
          proxy_read_timeout   600s;
          proxy_send_timeout   600s;
          send_timeout         600s;
        '';
      };
    };
  };
  meta = { };
}
