{
  config,
  pkgs,
  lib,
  ...
}:
with builtins;
let
  std = pkgs.lib;
  guix = config.services.guix;
in
{
  options = with lib; { };
  disabledModules = [ ];
  imports = lib.listFilePaths ./programs;
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

    environment.systemPackages = [
      pkgs.fastfetch

      pkgs.wineWowPackages.waylandFull
      pkgs.winetricks

      pkgs.nix-alien
    ];

    programs.appimage = {
      enable = true;
      binfmt = true;
    };

    programs.nix-ld = {
      enable = true;
      libraries = [
        pkgs.libGL
        pkgs.xorg.libX11
        pkgs.xorg.libXcursor
        pkgs.xorg.libXext
        pkgs.xorg.libXi
        pkgs.xorg.libXinerama
        pkgs.xorg.libXrandr
        pkgs.xorg.libXrender
        pkgs.xorg.libxcb
        pkgs.xorg.libXcomposite
        pkgs.xorg.libXdamage
        pkgs.xorg.libXfixes
        pkgs.xorg.libXtst
        pkgs.xorg.libXScrnSaver
        pkgs.xorg.libXxf86vm
        # for some games (like cataclysm:bn) to work
        pkgs.SDL2
        pkgs.SDL2_Pango
        pkgs.SDL2_gfx
        pkgs.SDL2_image
        pkgs.SDL2_mixer
        pkgs.SDL2_net
        pkgs.SDL2_sound
        pkgs.SDL2_ttf
        ## modloader64
        pkgs.glew
        pkgs.speexdsp
        pkgs.libsamplerate
        pkgs.sfml_2
        pkgs.openal
        pkgs.libvorbis
        pkgs.flac
        ## tes3cmd
        pkgs.libxcrypt-legacy
        # rpgmaker
        pkgs.nss
        pkgs.glib
        pkgs.nspr
        pkgs.cups
        pkgs.dbus
        pkgs.expat
        pkgs.alsa-lib
        pkgs.pango
        pkgs.cairo
        pkgs.at-spi2-atk
        pkgs.gtk3
        pkgs.gdk-pixbuf
        pkgs.libxkbcommon
        pkgs.libgbm
        pkgs.gnome2.GConf
        pkgs.fontconfig
        pkgs.freetype
        pkgs.gtk2
        pkgs.libnotify
        # misc
        pkgs.libdrm
      ];
    };
  };
  meta = { };
}
