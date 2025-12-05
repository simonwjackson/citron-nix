{
  description = "Nix package for Citron Nintendo Switch emulator";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    citron-src = {
      url = "git+https://git.citron-emu.org/Citron/Emulator.git?rev=4491abcdcee2a92fe3520db29f5b652006890ecd&submodules=1";
      flake = false;
    };

    nx-tzdb = {
      url = "https://github.com/lat9nq/tzdb_to_nx/releases/download/221202/221202.zip";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    citron-src,
    nx-tzdb,
  }: let
    supportedSystems = ["x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    packages = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        citron = pkgs.callPackage ./package.nix {
          src = citron-src;
          nx-tzdb = nx-tzdb;
        };
        default = self.packages.${system}.citron;
      }
    );

    overlays.default = final: prev: {
      citron = self.packages.${prev.system}.citron;
    };
  };
}
