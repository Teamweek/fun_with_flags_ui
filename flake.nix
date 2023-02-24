{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    pre-commit.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = { self, nixpkgs, pre-commit }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      checks = {
        pre-commit-check = pre-commit.lib.${system}.run {
          src = ./.;
          hooks = {
            mix-fmt = {
              enable = true;
              name = "Mix format";
              entry = "${pkgs.elixir_1_12}/bin/mix format --check-formatted";
              files = "\\.(ex|exs)$";
            };
          };
        };
      };

      devShells.${system}.default = pkgs.mkShell {
        inherit (self.checks.pre-commit-check) shellHook;

        buildInputs = with pkgs; [
          # core dependencies
          elixir_1_12
          erlang

          # Dev-related
          (elixir_ls.override { elixir = elixir_1_12; })
          inotify-tools
        ];
      };
    };
}
