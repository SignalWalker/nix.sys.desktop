{
  pkgs,
  ...
}:
{
  config = {
    programs.gamescope = {
      enable = true;
      capSysNice = true;
      args = [
        "--scaler fit"
        "--filter pixel"
        "--rt"
        # "--mangoapp"
        "--hdr-enabled"
        # "--expose-wayland"
      ];
    };

    users.extraGroups."gamemode".members = [ "ash" ];
    programs.gamemode = {
      enable = true;
      enableRenice = true;
      settings = {
        general = {
          renice = 10;
          desiredgov = "performance";
        };
        custom =
          let
            notify = "${pkgs.libnotify}/bin/notify-send --app-name=Gamemode --category=system --urgency=low";
          in
          {
            start = "${notify} 'Game mode enabled'";
            end = "${notify} 'Game mode disabled'";
          };
      };
    };

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # tcp 27036, udp 27031-27035
      localNetworkGameTransfers.openFirewall = true; # tcp 27040, udp 27036
      package = pkgs.steam.override {
        extraEnv = {
          # MANGOHUD = true;
        };
        # fix gamescope launch from within steam
        extraLibraries = p: [
          p.libxcursor
          p.libxi
          p.libxinerama
          p.libxscrnsaver
          p.libpng
          p.libpulseaudio
          p.libvorbis
          p.stdenv.cc.cc.lib
          p.libkrb5
          p.keyutils
        ];
      };
      extest.enable = false;
      extraCompatPackages = [
        pkgs.proton-ge-bin
      ];
      gamescopeSession = {
        enable = false;
      };
    };

    users.extraGroups."fusee".members = [ "ash" ];
    services.udev.extraRules = ''
      SUBSYSTEMS=="usb", ATTRS{manufacturer}=="NVIDIA Corp.", ATTRS{product}=="APX", GROUP="fusee"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="3000", GROUP="fusee"
    '';
  };
  meta = { };
}
