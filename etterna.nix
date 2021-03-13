# nix-shell etterna.nix
# export out=$PWD/build
# genericBuild

{ pkgs ? import <nixpkgs> {} }:

with pkgs; stdenv.mkDerivation rec {
  name = "Etterna";
  version = "0.70.3";

  hardeningDisable = [ "format" ];

  src = fetchFromGitHub {
    owner  = "etternagame";
    repo   = "etterna";
    rev    = "v${version}";
    sha256 = "1vgvg4x6jja97j95lq58f36g29szzl5xzk200wkjq7yxrskz50bj";
  };

  staticOpenSSL = openssl.override { static = true; };
  propagatedBuildInputs = [ staticOpenSSL
                            xorg.libX11
                            xorg.libXext
                            xorg.libXrandr
                            curl
                            libGLU
                            libpulseaudio
                            libogg
                            # alsaLib
                            # libjack2
                          ];

  nativeBuildInputs = [ cmake gnumake pkg-config ];
}
