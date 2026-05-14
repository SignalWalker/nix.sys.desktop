{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.lix-module.nixosModules.default
    inputs.agenix.nixosModules.age
    inputs.nix-index-database.nixosModules.nix-index
  ];
  config = {
    # assertions = [
    #   {
    #     assertion = config.nix.package.version >= pkgs.nix.version;
    #     message = "inputs.nix is out of date (${config.nix.package.version} < ${pkgs.nix.version})";
    #   }
    # ];

    environment.systemPackages = [
      inputs.nix-auth.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    nix = {
      gc = {
        automatic = true;
        dates = "weekly";
      };
      settings = {
        # NOTE :: use nix-auth for this; don't try to put access tokens here
        access-tokens = [ ];
      };
    };

    programs.command-not-found.enable = false; # doesn't work in a pure-flake system

    nixpkgs = {
      overlays = [
        inputs.mozilla.overlays.rust
        inputs.mozilla.overlays.firefox
        # inputs.wayland.overlays.default
        inputs.agenix.overlays.default

        inputs.thaw.overlays."package/thaw"

        inputs.nix-alien.overlays.default
      ];

      config = {
        permittedInsecurePackages = [
          # "electron-35.7.5"
          # "libsoup-2.74.3"
          # "qtwebengine-5.15.19"
        ];
        nvidia.acceptLicense = true;
      };
    };
  };
  meta = { };
}
