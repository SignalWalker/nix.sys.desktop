{
  description = "Nix configuration - personal desktop computer";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    alejandra = {
      url = "github:kamadorueda/alejandra";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sysbase = {
      url = "github:signalwalker/nix.sys.base";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.alejandra.follows = "alejandra";
    };
    syshome = {
      url = "github:signalwalker/nix.sys.home";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.alejandra.follows = "alejandra";
    };
    homelib = {
      url = "github:signalwalker/nix.home.lib";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.alejandra.follows = "alejandra";
      inputs.home-manager.follows = "home-manager";
    };
    homebase = {
      url = "github:signalwalker/nix.home.base";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.alejandra.follows = "alejandra";
      inputs.homelib.follows = "homelib";
      inputs.home-manager.follows = "home-manager";
    };
    homedesk = {
      url = "github:signalwalker/nix.home.desktop";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.alejandra.follows = "alejandra";
      inputs.mozilla.follows = "mozilla";
      inputs.ash-scripts.follows = "ash-scripts";
      inputs.polybar-scripts.follows = "polybar-scripts";
      inputs.wired.follows = "wired";
    };
    homedev = {
      url = "github:signalwalker/nix.home.dev";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.alejandra.follows = "alejandra";
      inputs.mozilla.follows = "mozilla";
    };
    homemedia = {
      url = "github:signalwalker/nix.home.media";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.alejandra.follows = "alejandra";
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
    ash-scripts = {
      url = "github:signalwalker/scripts-rs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.mozilla.follows = "mozilla";
    };
    ## x11
    polybar-scripts = {
      url = "github:polybar/polybar-scripts";
      flake = false;
    };
    wired = {
      url = "github:Toqozz/wired-notify";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    foundryvtt = {
      url = "github:reckenrode/nix-foundryvtt";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    wayland = {
      # url = "github:nix-community/nixpkgs-wayland";
      url = "github:Scrumplex/nixpkgs-wayland/remove-spdlog-override";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    # fw-fanctrl = {
    #   url = "github:mdvmeijer/fw-fanctrl-nix";
    #   flake = false;
    # };
    grub-theme-yorha = {
      url = "github:OliveThePuffin/yorha-grub-theme";
      flake = false;
    };

    napalm = {
      url = "github:nix-community/napalm";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cross-seed = {
      url = "github:cross-seed/cross-seed";
      flake = false;
    };
    autobrr = {
      url = "github:autobrr/autobrr";
      flake = false;
    };
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    deploy-rs,
    ...
  }:
    with builtins; let
      std = nixpkgs.lib;
      machines = ["artemis" "terra"];
    in {
      formatter = std.mapAttrs (system: pkgs: pkgs.default) inputs.alejandra.packages;
      overlays.default = final: prev: {
        cross-seed = import ./pkgs/cross-seed.nix {
          inherit inputs;
          pkgs = final;
        };
        autobrr = import ./pkgs/autobrr.nix {
          inherit inputs;
          pkgs = final;
        };
      };
      nixosModules = std.genAttrs machines (machine: {
        lib,
        pkgs,
        ...
      }: {
        options = {};
        imports =
          [
            inputs.sysbase.nixosModules.default
            inputs.syshome.nixosModules.default

            inputs.nix-index-database.nixosModules.nix-index
            inputs.foundryvtt.nixosModules.foundryvtt
            inputs.musnix.nixosModules.musnix
            inputs.agenix.nixosModules.age

            ./machine/${machine}.nix
          ]
          ++ (lib.signal.fs.path.listFilePaths ./nixos)
          ++ (std.optionals (machine == "artemis") [
            inputs.nixos-hardware.nixosModules.framework
          ])
          ++ (std.optionals (machine == "terra") [
            ]);
        config = lib.mkMerge [
          {
            networking.hostName = machine;
            networking.domain = lib.mkDefault "local";
            home-manager = {
              users = self.homeConfigurations;
            };
            nixpkgs.overlays = [
              self.overlays.default

              inputs.mozilla.overlays.rust
              inputs.mozilla.overlays.firefox
              inputs.wayland.overlays.default
              inputs.agenix.overlays.default
            ];
          }
          (lib.mkIf (machine == "artemis") {
            environment.systemPackages = [
              inputs.fw-ectool.packages.${pkgs.system}.default
            ];
            boot.loader.grub = {
              theme = "${inputs.grub-theme-yorha}/yorha-2256x1504";
            };
          })
          (lib.mkIf (machine == "terra") {
            # networking.domain = "home.ashwalker.net";
            # networking.fqdn = "home.ashwalker.net";
          })
        ];
      });
      homeConfigurations.ash = {
        config,
        lib,
        ...
      }: {
        imports =
          [
            inputs.homebase.homeManagerModules.default
            inputs.homedev.homeManagerModules.default
            inputs.homedesk.homeManagerModules.default
            inputs.homemedia.homeManagerModules.default

            inputs.nix-index-database.hmModules.nix-index
            inputs.agenix.homeManagerModules.age
          ]
          ++ (lib.signal.fs.path.listFilePaths ./hm);
        config = {
          nixpkgs.overlays = [
            inputs.mozilla.overlays.rust
            inputs.mozilla.overlays.firefox
          ];

          programs.guix.enable = false;
          # services.xremap.enable = lib.mkForce false;
          # services.xremap.services."primary".settings.modmap = [{remap."f20" = "micmute";}];
          signal.desktop.x11.enable = false;
          signal.desktop.wayland.compositor.sway.enable = true;
          signal.desktop.wayland.taskbar.enable = true;

          # home.keyboard = lib.mkIf (!(osConfig.signal.input.enable or false)) {
          #   # model = "pc104";
          #   layout = "us";
          #   options = [
          #     "caps:hyper"
          #     "grp_led:caps"
          #   ];
          # };
        };
      };
      nixosConfigurations = std.mapAttrs (machine: module:
        std.nixosSystem {
          system = null; # set in `config.nixpkgs.hostPlatform`
          modules = [
            module
          ];
          lib = std.extend (final: prev: {
            signal = inputs.homelib.lib;
          });
        })
      self.nixosModules;

      deploy.nodes = {
        "terra" = {
          hostname = "terra.ashwalker.net";
          remoteBuild = true;
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."terra";
          };
        };
        "artemis" = {
          hostname = "artemis.ashwalker.net";
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."artemis";
          };
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
