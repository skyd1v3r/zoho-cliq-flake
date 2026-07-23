{ stdenv, dpkg, autoPatchelfHook, fetchurl
, nspr, nss, gtk3, glib, libX11, libxkbcommon
, libxscrnsaver, libxcomposite, libxdamage, libxext
, libxfixes, libxi, libxrandr, libxcb
, zlib, alsa-lib, libpulseaudio
, makeWrapper
, lib
}:

stdenv.mkDerivation rec {
  pname = "zoho-cliq";
  version = "1.8.3";

  src = fetchurl {
    url = "https://downloads.zohocdn.com/chat-desktop/linux/cliq_${version}_amd64.deb";
    hash = "sha256-9XjnIJdgdPXysXXbEdwr2cBG7OS1z6E8s+oL3hhfRGU=";
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook makeWrapper ];

  buildInputs = [
    nspr nss gtk3 glib libX11 libxkbcommon
    libxscrnsaver libxcomposite libxdamage libxext
    libxfixes libxi libxrandr libxcb
    zlib stdenv.cc.cc.lib alsa-lib libpulseaudio
  ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
      mkdir -p $out/bin $out/share/applications
      cp -r opt/Cliq/* $out/bin/
      chmod +x $out/bin/cliq
  
      # Копируем иконки из стандартной папки
      cp -r usr/share/icons $out/share/
  
      # Создаём .desktop файл
      cat > $out/share/applications/zoho-cliq.desktop <<EOF
      [Desktop Entry]
      Name=Zoho Cliq
      Comment=Zoho Cliq Desktop Client
      Exec=$out/bin/cliq
      Icon=cliq
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
