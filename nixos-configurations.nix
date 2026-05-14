inputs:
top@{ lib, ... }:

lib.mapAttrs (
  name: module:
  lib.nixosSystem {
    system = null; # set in `config.nixpkgs.hostPlatform`
    specialArgs = {
      inherit inputs;
    };
    modules = [
      module
      # {
      #   _module.args.nixinate = {
      #     host = "${machine}.ashwalker.net";
      #     sshUser = "root";
      #     buildOn = "remote";
      #     substituteOnTarget = true;
      #     hermetic = false;
      #   };
      # }
    ];
    lib = lib.extend (
      final: prev: {
        inherit (import "${inputs.homebase}/lib.nix") listFilePaths;
      }
    );
  }
) top.config.flake.nixosModules
