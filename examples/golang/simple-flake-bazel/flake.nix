{
  description = "A Go example with Bazel and Nix flakes";

  inputs = {
    # nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2305.491812.tar.gz";
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in {
      devShell = pkgs.mkShell {
        buildInputs = [
          pkgs.go
          pkgs.bazel
        ];

        shellHook = ''
          export GOPATH=$PWD/go
          export PATH=$GOPATH/bin:$PATH
        '';
      };

      packages.default = pkgs.stdenv.mkDerivation {
        name = "zero-to-nix-go-bazel";
        src = ./.;

        buildInputs = [
          pkgs.go
          pkgs.bazel
        ];

        buildPhase = ''
          bazel build //cmd/zero-to-nix-go:zero-to-nix-go
        '';

        installPhase = ''
          mkdir -p $out/bin
          cp -r bazel-bin/cmd/zero-to-nix-go/zero-to-nix-go $out/bin/
        '';
      };
    });
    # let
    #   # Systems supported
    #   allSystems = [
    #     "x86_64-linux" # 64-bit Intel/AMD Linux
    #     "aarch64-linux" # 64-bit ARM Linux
    #     "x86_64-darwin" # 64-bit Intel macOS
    #     "aarch64-darwin" # 64-bit ARM macOS
    #   ];

    #   # Helper to provide system-specific attributes
    #   forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
    #     pkgs = import nixpkgs { inherit system; };
    #   });
    # in
    # {
    #   packages = forAllSystems ({ pkgs }: {
    #     default = pkgs.buildGoModule {
    #       name = "zero-to-nix-go";
    #       src = ./.;
    #       vendorSha256 = "sha256-Cy1/QqbO2MyYgqJZKxrt1FZzLSgXbhSK3ceFPUlFujw=";
    #     };
    #   });
    # };
}
