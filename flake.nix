{
  description = "Nix package for Citron Nintendo Switch emulator";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          citron = pkgs.callPackage ./package.nix { };
          default = self.packages.${system}.citron;
        }
      );

      overlays.default = final: prev: {
        citron = self.packages.${prev.system}.citron;
      };
    };
}
