top@{ ... }:
machines:

(top.lib.genAttrs machines (
  machine:
  {
    lib,
    ...
  }:
  {
    options = { };

    imports = [
      ./machine/${machine}.nix
    ]
    ++ (lib.listFilePaths ./nixos)
    ++ (lib.listFilePaths ./modules);

    config = lib.mkMerge [
      {
        networking.hostName = machine;
        networking.domain = lib.mkDefault "local";

        home-manager = {
          users = top.config.flake.homeConfigurations;
        };
      }
    ];
  }
))
// {
  "iso-installer" = (
    { pkgs, inputs, ... }:
    {
      imports = [
        inputs.sysbase.nixosModules.default
        inputs.lix-module.nixosModules.default
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel.nix"
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
      ];
      config = {
        networking = {
          hostName = "theia-installer";
        };
        users.users.ash = {
          password = "ash";
        };
        home-manager.users = {
          ash = (
            { ... }:
            {
              imports = [
                inputs.homebase.homeModules.default
              ];
              config = { };
            }
          );
        };
        environment.systemPackages = [
          inputs.nix-auth.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
        boot = {
          supportedFilesystems = [
            "btrfs"
            "f2fs"
            "vfat"
          ];
        };
        system.targets = {
          sleep.enable = false;
          suspend.enable = false;
          hibernate.enable = false;
          hybrid-sleep.enable = false;
        };
      };
    }
  );
}
