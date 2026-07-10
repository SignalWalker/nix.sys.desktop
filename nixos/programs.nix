{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = { };
  disabledModules = [ ];
  imports = lib.listFilePaths ./programs;
  config = {

    environment.systemPackages = [
      pkgs.fastfetch

      pkgs.wineWow64Packages.waylandFull
      pkgs.winetricks

    ];

    programs.appimage = {
      enable = true;
      binfmt = true;
    };

    programs.nix-ld = {
      enable = true;
      libraries = [
        pkgs.libGL
        pkgs.libx11
        pkgs.libxcursor
        pkgs.libxext
        pkgs.libxi
        pkgs.libxinerama
        pkgs.libxrandr
        pkgs.libxrender
        pkgs.libxcb
        pkgs.libxcomposite
        pkgs.libxdamage
        pkgs.libxfixes
        pkgs.libxtst
        pkgs.libxscrnsaver
        pkgs.libxxf86vm
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
        # pkgs.gnome2.GConf # NOTE :: removed from nixpkgs
        pkgs.fontconfig
        pkgs.freetype
        pkgs.gtk2
        pkgs.libnotify
        ## rpgmaker-linux
        pkgs.pulseaudio
        pkgs.libffi
        pkgs.libyaml
        # misc
        pkgs.libdrm
        # banjo recompiled
        pkgs.libsm
      ];
    };
  };
  meta = { };
}
