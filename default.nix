{ pkgs, lib }:

let
  version = "1.8.3";
  
  cliq-src = pkgs.stdenv.mkDerivation {
    name = "zoho-cliq-src-${version}";
    src = pkgs.fetchurl {
      url = "https://downloads.zohocdn.com/chat-desktop/linux/cliq_${version}_amd64.deb";
      hash = "sha256-9XjnIJdgdPXysXXbEdwr2cBG7OS1z6E8s+oL3hhfRGU=";
    };
    nativeBuildInputs = [ pkgs.dpkg ];
    unpackPhase = "dpkg-deb -x $src .";
    installPhase = ''
      mkdir -p $out
      cp -r opt $out/
      cp -r usr $out/
    '';
  };

  cliq-fhs = pkgs.buildFHSEnv {
    name = "zoho-cliq-fhs";
    
    targetPkgs = pkgs: with pkgs; [
      cliq-src
      
      # КРИТИЧНО: EGL и Wayland для PipeWire-захвата
      libglvnd
      wayland
      
      # Графика и X11
      mesa libgbm libdrm
      gtk3 glib pango cairo gdk-pixbuf atk at-spi2-atk
      libX11 libxkbcommon libxcomposite libxdamage
      libxext libxfixes libxrandr libxcb
      
      # Криптография
      nspr nss
      
      # Звук
      alsa-lib libpulseaudio
      
      # Системные
      dbus cups expat udev
      stdenv.cc.cc.lib
      
      # PipeWire и порталы
      pipewire wireplumber
      xdg-desktop-portal xdg-desktop-portal-gtk
      
      # Аппаратное декодирование
      libva libva-utils
    ];

    # Финальный оптимизированный запуск для Wayland + NixOS FHS
    runScript = ''
      #!/bin/sh
      export NIXOS_OZONE_WL=1
      
      exec ${cliq-src}/opt/Cliq/cliq \
        --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer,CanvasOopRasterization,VaapiVideoDecoder,WaylandWindowDecorations \
        --enable-gpu-rasterization \
        --enable-zero-copy \
        --disable-features=CalculateNativeWinOcclusion \
        --disable-gpu-sandbox \
        --ozone-platform=wayland \
        "$@"
    '';
  };

in
pkgs.stdenv.mkDerivation {
  name = "zoho-cliq-${version}";
  dontUnpack = true;
  
  installPhase = ''
    mkdir -p $out/bin $out/share/applications $out/share/icons
    
    cp -r ${cliq-src}/usr/share/icons/* $out/share/icons/ || true
    
    cat > $out/share/applications/zoho-cliq.desktop <<EOF
[Desktop Entry]
Name=Zoho Cliq
Comment=Zoho Cliq Desktop Client
Exec=${cliq-fhs}/bin/zoho-cliq-fhs
Icon=cliq
Type=Application
Categories=Network;InstantMessaging;
StartupWMClass=cliq
EOF

    ln -s ${cliq-fhs}/bin/zoho-cliq-fhs $out/bin/zoho-cliq
  '';

  meta = {
    description = "Zoho Cliq Desktop Client (FHS, Xwayland)";
    homepage = "https://www.zoho.com/cliq/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
