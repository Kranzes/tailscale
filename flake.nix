{
  description = "Tailscale as a nix flake";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.dream2nix.url = "github:nix-community/dream2nix";

  outputs = { self, nixpkgs, dream2nix }@inputs:
    let
      dream2nix = inputs.dream2nix.lib.init {
        systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
        config.projectRoot = ./.;
      };
    in
    dream2nix.makeFlakeOutputs {
      source = ./.;
      settings = [
        {
          builder = "gomod2nix";
          translator = "gomod2nix";
        }
      ];
    };
}

