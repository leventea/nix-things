# nix-shell etterna.nix
# genericBuild

{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  name = "Etterna";
  version = "0.70.3";


  hardeningDisable = [ "format" ];

  src = pkgs.fetchFromGitHub {
    owner  = "etternagame";
    repo   = "etterna";
    rev    = "v${version}";
    sha256 = "1vgvg4x6jja97j95lq58f36g29szzl5xzk200wkjq7yxrskz50bj";
  };

  staticOpenSSL = pkgs.openssl.override { static = true; };
  propagatedBuildInputs = with pkgs; [ staticOpenSSL
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

  nativeBuildInputs = with pkgs; [ cmake gnumake pkg-config ];
}
