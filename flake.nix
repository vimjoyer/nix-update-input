{
  description = "update-input";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      forAllSystems = function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ]
          (system: function nixpkgs.legacyPackages.${system});
    in {
      packages = forAllSystems (pkgs: {
        default = pkgs.writeShellScriptBin "update-input" ''
          input=$(                                           \
            nix flake metadata --json                        \
            | ${pkgs.jq}/bin/jq -r ".locks.nodes.root.inputs | keys[]" \
            | ${pkgs.fzf}/bin/fzf)
          commit=$(printf "yes\nno" | ${pkgs.fzf}/bin/fzf --prompt="Commit lock file? ")

          if [ "$commit" = "yes" ]; then
            nix flake update $input --commit-lock-file
          else
            nix flake update $input
          fi
        '';
      });
    };
}
