# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Nix flake for wokelangiser
#
# NOTE: guix.scm is the PRIMARY development environment. This flake is provided
# as a FALLBACK for contributors who use Nix instead of Guix. The .envrc checks
# for Guix first, then falls back to Nix.
#
# Usage:
#   nix develop          # Enter development shell
#   nix build            # Build the project
#   nix flake check      # Run checks
#   nix flake show       # Show flake outputs
#
# With direnv (.envrc already configured):
#   direnv allow         # Auto-enters shell on cd
#
# Identity, description, and dev-shell toolchain below are filled for wokelangiser.

{
  description = "wokelangiser — RSR-compliant project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Common development tools present in every RSR project.
        commonTools = with pkgs; [
          git
          just
          nickel
          curl
          bash
          coreutils
        ];

        # ---------------------------------------------------------------
        # Language-specific packages: uncomment the stacks you need.
        # ---------------------------------------------------------------
        #
        # Rust:
        #   rustc cargo clippy rustfmt rust-analyzer
        #
        # Elixir:
        #   elixir erlang
        #
        # Gleam:
        #   gleam erlang
        #
        # Zig:
        #   zig zls
        #
        # Haskell:
        #   ghc cabal-install haskell-language-server
        #
        # Idris2:
        #   idris2
        #
        # OCaml:
        #   ocaml dune_3 ocaml-lsp
        #
        # ReScript (via Deno):
        #   deno
        #
        # Julia:
        #   julia
        #
        # Ada/SPARK:
        #   gnat gprbuild
        #
        # ---------------------------------------------------------------
        languageTools = with pkgs; [
          # Rust (CLI + codegen)
          rustc
          cargo
          clippy
          rustfmt
          rust-analyzer
          # Idris2 (ABI proofs)
          idris2
          # Zig (FFI bridge)
          zig
        ];

      in
      {
        # ---------------------------------------------------------------
        # Development shell — `nix develop`
        # ---------------------------------------------------------------
        devShells.default = pkgs.mkShell {
          name = "wokelangiser-dev";

          buildInputs = commonTools ++ languageTools;

          # Environment variables available inside the shell.
          env = {
            PROJECT_NAME = "wokelangiser";
            RSR_TIER = "infrastructure";
          };

          shellHook = ''
            echo ""
            echo "  wokelangiser — development shell"
            echo "  Nix:    $(nix --version 2>/dev/null || echo 'unknown')"
            echo "  Just:   $(just --version 2>/dev/null || echo 'not found')"
            echo ""
            echo "  Run 'just' to see available recipes."
            echo ""

            # Source .envrc manually when direnv is not managing the shell.
            # This keeps project env vars (PROJECT_NAME, DATABASE_URL, etc.)
            # consistent whether you enter via 'nix develop' or 'direnv allow'.
            if [ -z "''${DIRENV_IN_ENVRC:-}" ] && [ -f .envrc ]; then
              # Only source the non-nix parts to avoid recursion.
              export PROJECT_NAME="wokelangiser"
              export RSR_TIER="infrastructure"
              if [ -f .env ]; then
                set -a
                . .env
                set +a
              fi
            fi
          '';
        };

        # ---------------------------------------------------------------
        # Package — `nix build`
        # ---------------------------------------------------------------
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "wokelangiser";
          version = "0.1.0";

          src = self;

          # TODO: Replace with real build instructions.
          # Examples:
          #
          # Rust (use rustPlatform.buildRustPackage instead of stdenv):
          #   packages.default = pkgs.rustPlatform.buildRustPackage { ... };
          #
          # Elixir (use mixRelease):
          #   packages.default = pkgs.beamPackages.mixRelease { ... };
          #
          # Zig:
          #   buildPhase = "zig build -Doptimize=ReleaseSafe";

          buildPhase = ''
            echo "TODO: Add build commands for wokelangiser"
          '';

          installPhase = ''
            mkdir -p $out/share/doc
            cp README.adoc $out/share/doc/ 2>/dev/null || true
          '';

          meta = with pkgs.lib; {
            description = "Add consent patterns, accessibility annotations, i18n hooks, and cultural sensitivity markers to existing code via WokeLang";
            homepage = "https://github.com/hyperpolymath/wokelangiser";
            license = licenses.mpl20; # MPL-2.0 extends MPL-2.0
            maintainers = [];
            platforms = [ "x86_64-linux" "aarch64-linux" ];
          };
        };
      }
    );
}
