{
  description = "SDL_shadercross";

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
                  spirv-cross = prev.spirv-cross.overrideAttrs (oldAttrs: {
                    cmakeFlags = [
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
            pname = "SDL_shadercross";
            version = "unstable";

            src = pkgs.fetchFromGitHub {
              owner = "libsdl-org";
              repo = "SDL_shadercross";
              rev = "main";
              sha256 = "sha256-IMWgIiuhpoydHtpsiDZ34eDyKBWLTtb/hX+sUCb3jOA=";
            };

            nativeBuildInputs = with pkgs; [
              pkg-config
              autoPatchelfHook
              cmake
            ];

            buildInputs = with pkgs; [
              spirv-cross
              directx-shader-compiler
              sdl3
            ];

            installPhase = ''
              mkdir -p $out/bin
              cp shadercross $out/bin/
            '';
          };
        }
      );
    };
}
