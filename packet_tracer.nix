# nix-shell -p 'qt5.callPackage ./packet_tracer.nix {}' --run packettracer
# credit to: https://gist.github.com/buckley310
# original gist: https://gist.github.com/buckley310/b4e718e71fb1c7403fb4ceb8fabbc1c4 

{ stdenv
, alsaLib
, autoPatchelfHook
, buildFHSUserEnv
, dbus
, dpkg
, expat
, fetchurl
, fontconfig
, glib
, libdrm
, libglvnd
, libpulseaudio
, libudev0-shim
, libxkbcommon
, libxml2
, libxslt
, makeDesktopItem
, makeWrapper
, mkDerivation
, nspr
, nss
, xlibs
}:

let
  version = "8.0.0";

  srcName =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      "PacketTracer_800_amd64_build212_final.deb"
    else throw "Unsupported system: ${stdenv.hostPlatform.system}";

  ptFiles = mkDerivation {
    name = "PacketTracer";
    inherit version;

    src = fetchurl {
      url = "https://archive.org/download/packet-tracer-800-build-212-mac-notarized/${srcName}";
      sha256 = "c9a78f9d1ee63fa421d3c531e9e1c209e425ba84d78c8e606594e4e59df535c9";
    };

    nativeBuildInputs = [
      alsaLib
      autoPatchelfHook
      dbus
      dpkg
      expat
      fontconfig
      glib
      libdrm
      libglvnd
      libpulseaudio
      libudev0-shim
      libxkbcommon
      libxml2
      libxslt
      makeWrapper
      nspr
      nss
      xlibs.libICE
      xlibs.libSM
      xlibs.libX11
      xlibs.libxcb
      xlibs.libXcomposite
      xlibs.libXcursor
      xlibs.libXdamage
      xlibs.libXext
      xlibs.libXfixes
      xlibs.libXi
      xlibs.libXrandr
      xlibs.libXrender
      xlibs.libXScrnSaver
      xlibs.xcbutilimage
      xlibs.xcbutilkeysyms
      xlibs.xcbutilrenderutil
      xlibs.xcbutilwm
    ];

    dontUnpack = true;
    installPhase = ''
      dpkg-deb -x $src $out
      chmod 755 "$out"
      makeWrapper "$out/opt/pt/bin/PacketTracer" "$out/bin/packettracer" \
          --prefix LD_LIBRARY_PATH : "$out/opt/pt/bin"
    '';
  };

  desktopItem = makeDesktopItem {
    name = "cisco-pt.desktop";
    desktopName = "Packet Tracer";
    icon = "${ptFiles}/opt/pt/art/app.png";
    exec = "packettracer %f";
    mimeType = "application/x-pkt;application/x-pka;application/x-pkz;";
  };

in
buildFHSUserEnv {
  name = "packettracer";
  runScript = "${ptFiles}/bin/packettracer";
  targetPkgs = pkgs: [ libudev0-shim ];

  extraInstallCommands = ''
    mkdir -p "$out/share/applications"
    cp "${desktopItem}"/share/applications/* "$out/share/applications/"
  '';
}
