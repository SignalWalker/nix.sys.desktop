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

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixinate = {
      url = "github:matthewcroughan/nixinate";
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
    # cross-seed = {
    #   url = "github:cross-seed/cross-seed";
    #   flake = false;
    # };
    autobrr = {
      url = "github:autobrr/autobrr";
      flake = false;
    };
    mylar3 = {
      url = "github:mylar3/mylar3";
      # inputs.nixpkgs.follows = "nixpkgs";
      flake = false;
    };
    kaizoku = {
      url = "github:oae/kaizoku";
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

    websurfx = {
      url = "github:neon-mmd/websurfx";
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

    # anubis = {
    #   url = "github:signalwalker/nix.service.anubis";
    # };

    # nixgl = {
    #   url = "github:nix-community/nixgl";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    openmw-nix = {
      url = "git+https://codeberg.org/PopeRigby/openmw-nix.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    openmw-src = {
      url = "github:openmw/openmw";
      flake = false;
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
    inputs@{
      self,
      nixpkgs,
      deploy-rs,
      ...
    }:
    let
      std = nixpkgs.lib;
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      nixpkgsFor = std.genAttrs systems (
        system:
        import nixpkgs {
          localSystem = builtins.currentSystem or system;
          crossSystem = system;
          overlays = [ ];
        }
      );
      machines = [
        "artemis"
        "terra"
      ];
    in
    {
      formatter = std.mapAttrs (system: pkgs: pkgs.nixfmt-rfc-style) nixpkgsFor;
      overlays.default = final: prev: {
        # cross-seed = import ./pkgs/cross-seed.nix {
        #   inherit inputs;
        #   pkgs = final;
        # };
        autobrr = import ./pkgs/autobrr.nix {
          inherit inputs;
          pkgs = final;
        };
        mylar3 = import ./pkgs/mylar3.nix {
          inherit inputs;
          pkgs = final;
        };
        kaizoku = import ./pkgs/kaizoku.nix {
          inherit inputs;
          pkgs = final;
        };
      };
      packages."x86_64-linux" =
        # let
        #   pkgs = import nixpkgs {
        #     localSystem = "x86_64-linux";
        #     crossSystem = "x86_64-linux";
        #     overlays = [ self.overlays.default ];
        #   };
        # in
        {
          # inherit
          #   (pkgs)
          #   cross-seed
          #   autobrr
          #   mylar3
          #   kaizoku
          #   ;
        };
      nixosModules = std.genAttrs machines (
        machine:
        {
          lib,
          pkgs,
          ...
        }:
        {
          options = { };

          imports = [
            inputs.sysbase.nixosModules.default

            inputs.lix-module.nixosModules.default

            inputs.disko.nixosModules.disko
            inputs.impermanence.nixosModules.impermanence

            inputs.nix-index-database.nixosModules.nix-index
            inputs.foundryvtt.nixosModules.foundryvtt
            inputs.musnix.nixosModules.musnix
            inputs.agenix.nixosModules.age

            inputs.auto-cpufreq.nixosModules.default

            inputs.stylix.nixosModules.stylix

            # inputs.anubis.nixosModules.default

            ./machine/${machine}.nix
          ]
          ++ (lib.listFilePaths ./nixos)
          ++ (lib.listFilePaths ./modules)
          ++ (std.optionals (machine == "artemis") [
            inputs.nixos-hardware.nixosModules.framework-13th-gen-intel
          ])
          ++ (std.optionals (machine == "terra") [
            inputs.nixos-hardware.nixosModules.common-pc
            inputs.nixos-hardware.nixosModules.common-pc-ssd

            inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only

            inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime

            inputs.minecraft.nixosModules.default

            inputs.simple-nixos-mailserver.nixosModules.default

            inputs.nix-serve-ng.nixosModules.default
          ]);

          config = lib.mkMerge [
            {
              # assertions = [
              #   {
              #     assertion = config.nix.package.version >= pkgs.nix.version;
              #     message = "inputs.nix is out of date (${config.nix.package.version} < ${pkgs.nix.version})";
              #   }
              # ];
              warnings = [
                "using lix instead of nix"
              ];

              environment.systemPackages = [
                inputs.nix-auth.packages.${pkgs.stdenv.hostPlatform.system}.default
              ];

              networking.hostName = machine;
              networking.domain = lib.mkDefault "local";

              home-manager = {
                users = self.homeConfigurations;
              };

              nixpkgs.overlays = [
                self.overlays.default

                inputs.mozilla.overlays.rust
                inputs.mozilla.overlays.firefox
                # inputs.wayland.overlays.default
                inputs.agenix.overlays.default

                inputs.thaw.overlays."package/thaw"

                # inputs.eww.overlays.default

                inputs.nix-alien.overlays.default

                # inputs.nixgl.overlay
              ];

              nixpkgs.config.packageOverrides = pkgs: {
                # gamescope = pkgs.gamescope.override {wlroots = std.trivial.warn "overriding gamescope wlroots" pkgs.wlroots_0_17;};
              };

              nixpkgs.config.permittedInsecurePackages = [
                "electron-35.7.5"
                "libsoup-2.74.3"
                "qtwebengine-5.15.19"
                # "dotnet-sdk-6.0.428"
                # "aspnetcore-runtime-6.0.36"
                # "aspnetcore-runtime-wrapped-6.0.36"
                # "dotnet-sdk-wrapped-6.0.428"
              ];
              nixpkgs.config.nvidia.acceptLicense = true;

            }
            (lib.mkIf (machine == "artemis") {
              environment.systemPackages = [
                inputs.fw-ectool.packages.${pkgs.stdenv.hostPlatform.system}.default
              ];
              boot.loader.grub = {
                theme = "${inputs.grub-theme-yorha}/yorha-2256x1504";
              };
              stylix.targets.grub.enable = false;
            })
            (lib.mkIf (machine == "terra") {
              services.nix-serve.package =
                inputs.nix-serve-ng.packages.${pkgs.stdenv.hostPlatform.system}.lix-serve-ng;
              # services.websurfx.package = inputs.websurfx.packages.${pkgs.system}.websurfx;

              # networking.domain = "home.ashwalker.net";
              # networking.fqdn = "home.ashwalker.net";
              # services.mylar3.package = inputs.mylar3.packages.${pkgs.system}.mylar3;
            })
          ];
        }
      );

      homeConfigurations = {
        ash =
          {
            config,
            lib,
            pkgs,
            ...
          }:
          {
            imports = [
              inputs.homebase.homeModules.default
              inputs.homedesk.homeModules.default

              inputs.nix-index-database.homeModules.nix-index
              inputs.agenix.homeManagerModules.age

              ./hm/shared.nix
              # TODO :: per-machine homeconfig
              # ./hm/${machine}.nix
            ];
            config = {
              programs.guix.enable = false;

              # desktop.wayland.compositor.sway.enable = true;

              # wayland.windowManager.hyprland.pyprland.package =
              #   inputs.pyprland.packages.${pkgs.stdenv.hostPlatform.system}.pyprland;

              home.packages = [
                # (openmw-dev.overrideAttrs (
                #   final: prev: {
                #     src = inputs.openmw-src;
                #   }
                # ))
                # openmw-validator
                # plox
                # umo # build failure 2025-05-24
                # delta-plugin
                # groundcoverify
              ];
            };
          };
      };

      nixosConfigurations =
        std.mapAttrs
          (
            machine: module:
            std.nixosSystem {
              system = null; # set in `config.nixpkgs.hostPlatform`
              specialArgs = {
                inherit inputs;
              };
              modules = [
                module
                {
                  _module.args.nixinate = {
                    host = "${machine}.ashwalker.net";
                    sshUser = "root";
                    buildOn = "remote";
                    substituteOnTarget = true;
                    hermetic = false;
                  };
                }
              ];
              lib = std.extend (
                final: prev: {
                  inherit (import "${inputs.homebase}/lib.nix") listFilePaths;
                }
              );
            }
          )
          (
            {
              "iso-installer" = (
                { pkgs, ... }:
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
            // self.nixosModules
          );

      deploy = {
        sshUser = "root";
        nodes = {
          "terra" = {
            hostname = "terra.ashwalker.net";
            remoteBuild = true;
            profiles = {
              system = {
                user = "root";
                path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."terra";
              };
            };
          };
          "artemis" = {
            hostname = "artemis.ashwalker.net";
            profiles = {
              system = {
                user = "root";
                path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."artemis";
              };
            };
          };
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
