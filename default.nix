{ stdenv, dpkg, autoPatchelfHook, fetchurl
, nspr, nss, gtk3, glib, libX11, libxkbcommon
, libxscrnsaver, libxcomposite, libxdamage, libxext
, libxfixes, libxi, libxrandr, libxcb
, zlib, alsa-lib, libpulseaudio
, makeWrapper
, lib
, bash
, mesa
, libgbm
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
    mesa
    libgbm
  ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/applications $out/share/icons/hicolor/256x256/apps
  
    cp -r opt/Cliq/* $out/bin/
    chmod +x $out/bin/cliq
  
    cp -r usr/share/icons/* $out/share/icons/
  
    # Создаём обёртку вручную (скрипт)
    cat > $out/bin/zoho-cliq <<EOF
  #!/nix/store/34dkjp1wxxh6djsvxk8nhvzp0izasds0-glibc-2.42-67/bin/bash
  export LD_LIBRARY_PATH=${lib.makeLibraryPath buildInputs}:$out/bin
  exec $out/bin/cliq "\$@"
  EOF
    chmod +x $out/bin/zoho-cliq
  
    # .desktop файл
    cat > $out/share/applications/zoho-cliq.desktop <<EOF
    [Desktop Entry]
    Name=Zoho Cliq
    Comment=Zoho Cliq Desktop Client
    Exec=$out/bin/zoho-cliq
    Icon=cliq
    Type=Application
    Categories=Network;InstantMessaging;
    EOF
  '';

  meta = {
    description = "Zoho Cliq Desktop Client";
    homepage = "https://www.zoho.com/cliq/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
