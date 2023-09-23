{
  description = "update-input";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          packages.default = pkgs.writeShellScriptBin "update-input" ''
            input=$(nix flake metadata --json | ${pkgs.jq}/bin/jq ".locks.nodes.root.inputs[]" | sed "s/\"//g" | ${pkgs.fzf}/bin/fzf)
            nix flake lock --update-input $input
          '';
        }
      );
}
