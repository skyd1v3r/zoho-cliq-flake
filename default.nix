{ stdenv, dpkg, autoPatchelfHook, fetchurl
, nspr, nss, gtk3, glib, libX11, libxkbcommon, xorg
, zlib, alsa-lib, libpulseaudio
, makeWrapper
, lib
}:

stdenv.mkDerivation rec {
  pname = "zoho-cliq";
  version = "1.8.3";

  src = fetchurl {
    url = "https://downloads.zohocdn.com/chat-desktop/linux/cliq_${version}_amd64.deb";
    hash = "sha256-54eed5a772f68320f3906bec5920e3a19da904abdace10f985b87859015eef89";
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook makeWrapper ];

  buildInputs = [
    nspr nss gtk3 glib libX11 libxkbcommon
    xorg.libXScrnSaver xorg.libXcomposite xorg.libXdamage xorg.libXext
    xorg.libXfixes xorg.libXi xorg.libXrandr xorg.libxcb
    zlib stdenv.cc.cc.lib alsa-lib libpulseaudio
  ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/applications $out/share/icons/hicolor/256x256/apps
    cp -r opt/Cliq/* $out/bin/
    chmod +x $out/bin/cliq
    cp $out/bin/resources/app/app/images/appicon.png \
       $out/share/icons/hicolor/256x256/apps/zoho-cliq.png
    cat > $out/share/applications/zoho-cliq.desktop <<EOF
    [Desktop Entry]
    Name=Zoho Cliq
    Comment=Zoho Cliq Desktop Client
    Exec=$out/bin/cliq
    Icon=zoho-cliq
    Type=Application
    Categories=Network;InstantMessaging;
    EOF
    makeWrapper $out/bin/cliq $out/bin/.cliq-wrapper \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
  '';

  postFixup = ''
    mv $out/bin/.cliq-wrapper $out/bin/cliq
  '';

  meta = {
    description = "Zoho Cliq Desktop Client";
    homepage = "https://www.zoho.com/cliq/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
