{
  stdenv,
  lib,
  fetchurl,
  alsa-lib,
  atk,
  cairo,
  cups,
  udev,
  libdrm,
  libgbm,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libappindicator-gtk3,
  libnotify,
  nspr,
  nss,
  pango,
  systemd,
  xorg,
  autoPatchelfHook,
  wrapGAppsHook3,
  runtimeShell,
  gsettings-desktop-schemas,
}:

let
  versionSuffix = "20250428154451.19f9cfeddb";
in

stdenv.mkDerivation rec {
  pname = "keybase-gui";
  version = "6.5.1"; # Find latest version and versionSuffix from https://prerelease.keybase.io/deb/dists/stable/main/binary-amd64/Packages

  src = fetchurl {
    url = "https://s3.amazonaws.com/prerelease.keybase.io/linux_binaries/deb/keybase_${version + "-" + versionSuffix}_amd64.deb";
    hash = "sha256-PCKi1lavGwLbCoMTMG4h6PJTIzwRAu542eYqDDKzU4Y=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gsettings-desktop-schemas
    gtk3
    libappindicator-gtk3
    libnotify
    nspr
    nss
    pango
    systemd
    xorg.libX11
    xorg.libXScrnSaver
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    xorg.libxcb
    libdrm
    libgbm
  ];

  runtimeDependencies = [
    (lib.getLib udev)
    libappindicator-gtk3
  ];

  dontBuild = true;
  dontConfigure = true;
  dontPatchELF = true;

  unpackPhase = ''
    ar xf $src
    tar xf data.tar.xz
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv usr/share $out/share
    mv opt/keybase $out/share/

    cat > $out/bin/keybase-gui <<EOF
    #!${runtimeShell}

    checkFailed() {
      if [ "\$NIX_SKIP_KEYBASE_CHECKS" = "1" ]; then
        return
      fi
      echo "Set NIX_SKIP_KEYBASE_CHECKS=1 if you want to skip this check." >&2
      exit 1
    }

    if [ ! -S "\$XDG_RUNTIME_DIR/keybase/keybased.sock" ]; then
      echo "Keybase service doesn't seem to be running." >&2
      echo "You might need to run: keybase service" >&2
      checkFailed
    fi

    if [ -z "\$(keybase status | grep kbfsfuse)" ]; then
      echo "Could not find kbfsfuse client in keybase status." >&2
      echo "You might need to run: kbfsfuse" >&2
      checkFailed
    fi

    exec $out/share/keybase/Keybase \''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}} "\$@"
    EOF
    chmod +x $out/bin/keybase-gui

    substituteInPlace $out/share/applications/keybase.desktop \
      --replace run_keybase $out/bin/keybase-gui
  '';

  meta = with lib; {
    homepage = "https://www.keybase.io/";
    description = "Keybase official GUI";
    mainProgram = "keybase-gui";
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [
      avaq
      rvolosatovs
      puffnfresh
      np
      Br1ght0ne
      shofius
      ryand56
    ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.bsd3;
  };
}
