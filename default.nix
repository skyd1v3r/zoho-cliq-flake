{ stdenv, dpkg, autoPatchelfHook, fetchurl
, nspr, nss, gtk3, glib, libX11, libxkbcommon, xorg
, zlib, stdenv, alsa-lib, libpulseaudio
, makeWrapper
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
    # Распаковываем .deb архив
    dpkg-deb -x $src .
  '';

  installPhase = ''
    # Создаём основные директории
    mkdir -p $out/bin $out/share/applications $out/share/icons/hicolor/256x256/apps

    # Копируем все файлы приложения
    cp -r opt/Cliq/* $out/bin/

    # Делаем бинарник исполняемым
    chmod +x $out/bin/cliq

    # Копируем иконку в стандартную папку
    cp $out/bin/resources/app/app/images/appicon.png \
       $out/share/icons/hicolor/256x256/apps/zoho-cliq.png

    # Создаём .desktop файл
    cat > $out/share/applications/zoho-cliq.desktop <<EOF
    [Desktop Entry]
    Name=Zoho Cliq
    Comment=Zoho Cliq Desktop Client
    Exec=$out/bin/cliq
    Icon=zoho-cliq
    Type=Application
    Categories=Network;InstantMessaging;
    EOF

    # Создаём обёртку для правильного LD_LIBRARY_PATH (на случай, если autoPatchelfHook не справится)
    makeWrapper $out/bin/cliq $out/bin/.cliq-wrapper \
      --prefix LD_LIBRARY_PATH : ${stdenv.lib.makeLibraryPath buildInputs}
  '';

  # autoPatchelfHook автоматически исправляет rpath бинарников
  # а makeWrapper создаёт обёртку с LD_LIBRARY_PATH (дублируем для надёжности)
  postFixup = ''
    # Перемещаем обёртку на место оригинального бинарника
    mv $out/bin/.cliq-wrapper $out/bin/cliq
  '';

  meta = {
    description = "Zoho Cliq Desktop Client";
    homepage = "https://www.zoho.com/cliq/";
    license = stdenv.lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
