# citron-nix

Nix flake for [Citron](https://citron-emu.org), a Nintendo Switch emulator forked from yuzu.

## Usage

### Run directly

```bash
nix run github:simonwjackson/citron-nix
```

### Add to flake inputs

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    citron.url = "github:simonwjackson/citron-nix";
  };

  outputs = { nixpkgs, citron, ... }: {
    # Use the overlay
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        {
          nixpkgs.overlays = [ citron.overlays.default ];
          environment.systemPackages = [ pkgs.citron ];
        }
      ];
    };
  };
}
```

### Build locally

```bash
nix build github:simonwjackson/citron-nix
./result/bin/citron
```

## Version

Current version: **0.11.0**

## License

GPL-2.0-or-later (same as Citron)
