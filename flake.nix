{
  description = "Tailscale as a nix flake";

  # Nixpkgs version to use.
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: nixpkgs.legacyPackages.${system});
    in
    {

      # The packages output of the flake
      packages = forAllSystems (system: { tailscale = nixpkgsFor.${system}.callPackage ./nix/default.nix { inherit self; }; });

      # The NixOS module provided by this flake
      nixosModules.tailscale-dev = { imports = [ ./nix/module.nix ]; };

      # The default package used when running 'nix build'
      defaultPackage = forAllSystems (system: self.packages.${system}.tailscale);
    };
}
