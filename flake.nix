{
  description = "Nix configuration - personal desktop computer";
  inputs = {
    # TODO :: switch to nixos-unstable
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix = {
      type = "github";
      owner = "NixOS";
      repo = "nix";
      ref = "2.23.3";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    lix = {
      url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
      flake = false;
    };

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.lix.follows = "lix";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      # NOTE :: see `lib` section in https://flake.parts/module-arguments.html
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sysbase = {
      url = "github:signalwalker/nix.sys.base";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    homebase = {
      url = "github:signalwalker/nix.home.base";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    homedesk = {
      url = "github:signalwalker/nix.home.desktop";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.stylix.follows = "stylix";
      # inputs.wired.follows = "wired";
    };
    # base
    # multi
    mozilla = {
      url = "github:mozilla/nixpkgs-mozilla";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # desk
    ## x11
    # wired = {
    #   url = "github:Toqozz/wired-notify";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # foundryvtt = {
    #   url = "github:reckenrode/nix-foundryvtt";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nix-index = {
      url = "github:nix-community/nix-index";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # wayland = {
    #   url = "github:nix-community/nixpkgs-wayland";
    #   # url = "github:Scrumplex/nixpkgs-wayland/remove-spdlog-override";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # hardware-specific
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      # this doesn't actually take any inputs
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    fw-ectool-src = {
      url = "github:FrameworkComputer/EmbeddedController";
      flake = false;
    };
    fw-ectool = {
      url = "github:ssddq/fw-ectool";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.ec-git.follows = "fw-ectool-src";
      inputs.ec-local.follows = "fw-ectool-src";
    };

    grub-theme-yorha = {
      url = "github:OliveThePuffin/yorha-grub-theme";
      flake = false;
    };

    minecraft = {
      url = "github:signalwalker/cfg.minecraft.modpack/playground";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    thaw = {
      url = "github:snowfallorg/thaw";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    eww = {
      url = "github:elkowar/eww";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    auto-cpufreq = {
      url = "github:AdnanHodzic/auto-cpufreq";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      # inputs.nixpkgs.follows = "nixpkgs"; # commented out for the cache
    };
    hyprqt6engine = {
      url = "github:hyprwm/hyprqt6engine";
      # inputs.nixpkgs.follows = "nixpkgs"; # commented out for the cache
    };

    pyprland = {
      url = "github:hyprland-community/pyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    "nix-auth" = {
      url = "github:numtide/nix-auth";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-serve-ng = {
      url = "github:aristanetworks/nix-serve-ng";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      top@{
        ...
      }:
      {

        flake = {
          nixosModules = (import ./nixos-modules.nix) top [
            "artemis"
            "terra"
          ];

          homeConfigurations = (import ./home-configurations.nix) inputs top;

          nixosConfigurations = (import ./nixos-configurations.nix) inputs top;
        };
        systems = [ "x86_64-linux" ];
        perSystem =
          { pkgs, ... }:
          {
            formatter = pkgs.nixfmt;
          };
      }
    );
}

