{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  guix = config.services.guix;
in {
  options = with lib; {};
  disabledModules = [];
  imports = lib.signal.fs.path.listFilePaths ./programs;
  config = {
    services.guix = {
      enable = false; # FIX :: build failure as of 2024-08-19
      extraArgs = [
        "--discover=yes"
        "--substitute-urls=https://bordeaux.guix.gnu.org https://ci.guix.gnu.org https://substitutes.nonguix.org"
      ];
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

    environment.systemPackages = with pkgs; [
      fastfetch

      wineWowPackages.waylandFull
      winetricks

      nix-alien
    ];

    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        libGL
        xorg.libX11
        xorg.libXcursor
        xorg.libXext
        xorg.libXi
        xorg.libXinerama
        xorg.libXrandr
        xorg.libXrender
        xorg.libxcb
        xorg.libXcomposite
        xorg.libXdamage
        xorg.libXfixes
        xorg.libXtst
        xorg.libXScrnSaver
        # for some games (like cataclysm:bn) to work
        SDL2
        SDL2_Pango
        SDL2_gfx
        SDL2_image
        SDL2_mixer
        SDL2_net
        SDL2_sound
        SDL2_ttf
        ## modloader64
        glew
        speexdsp
        libsamplerate
        sfml_2
        openal
        libvorbis
        flac
        # rpgmaker
        nss
        glib
        nspr
        cups
        dbus
        expat
        alsa-lib
        pango
        cairo
        at-spi2-atk
        gtk3
        gdk-pixbuf
      ];
    };
  };
  meta = {};
}
