{
  description = "SDL3_shadercross";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      forEachSystem =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (
          system:
          f {
            pkgs = import nixpkgs {
              inherit system;
              overlays = [
                (final: prev: {
                  spirv-cross = prev.spirv-cross.overrideAttrs (old: {
                    cmakeFlags = (old.cmakeFlags or []) ++ [
                      "-DSPIRV_CROSS_ENABLE_C_API=ON"
                      "-DSPIRV_CROSS_SHARED=ON"
                      "-DBUILD_SHARED_LIBS=ON"
                    ];
                  });
                })
              ];
            };
          }
        );
    in
    {
      packages = forEachSystem (
        { pkgs }:
        {
          default = pkgs.stdenv.mkDerivation {
            pname = "SDL3_shadercross";
            version = "unstable";

            src = pkgs.fetchFromGitHub {
              owner = "libsdl-org";
              repo = "SDL_shadercross";
              rev = "main";
              sha256 = "sha256-2kpW4AN5eYPY3GxxDpH++nVHtBhSVv5FM2X4I+F2iAU=";
            };

            nativeBuildInputs = with pkgs; [
              cmake
              pkg-config
            ];

            buildInputs = with pkgs; [
              sdl3
              spirv-cross
              directx-shader-compiler
            ];

            cmakeFlags = [
              "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
              "-DSDLSHADERCROSS_INSTALL=ON"
              "-DSDLSHADERCROSS_CLI=ON"
              "-DSDLSHADERCROSS_VENDORED=OFF"
              "-DSDLSHADERCROSS_SPIRVCROSS_SHARED=ON"
              "-DSDLSHADERCROSS_INSTALL_MAN=OFF"
              "-DSDLSHADERCROSS_INSTALL_CPACK=OFF"
              "-DBUILD_SHARED_LIBS=ON"
            ];
          };
        }
      );
    };
}
