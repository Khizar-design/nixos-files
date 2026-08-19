{
  lib,
  fetchFromGitHub,
  python3Packages,
  bluez,
  systemd,
  glib,
  gtk4,
  libadwaita,
  libsecret,
  gobject-introspection,
  wrapGAppsHook4,
  quickshell,
  # The Qt/Kirigami client pulls in pyside6 + the KDE stack; off by default.
  withQt ? false,
  kdePackages,
  withGtk ? true,
  withQuickshell ? false,
}:

let
  bluetoothd = "${bluez}/libexec/bluetooth/bluetoothd";
  obexd = "${bluez}/libexec/bluetooth/obexd";
in
python3Packages.buildPythonApplication rec {
  pname = "blueferry";
  version = "0.7.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "erikwb";
    repo = "blueferry";
    tag = "v${version}";
    hash = "sha256-xQpqZ4exzHy0zs/XWUta18u4zqfNC0ioBfEW36GbA5w=";
  };

  build-system = with python3Packages; [
    setuptools
    wheel
  ];

  dependencies =
    with python3Packages;
    [
      cryptography
      typer
      dbus-python
      pygobject3
      textual
    ]
    ++ lib.optional withQt pyside6;

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook4
  ];

  buildInputs =
    [
      glib
      libsecret
    ]
    ++ lib.optionals withGtk [
      gtk4
      libadwaita
    ]
    ++ lib.optionals withQt [
      kdePackages.kirigami
      kdePackages.qqc2-desktop-style
    ];

  # buildPythonApplication does its own wrapping; fold the gapps env into it.
  dontWrapGApps = true;
  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  # BlueFerry is written for FHS distros and hardcodes absolute tool paths so a
  # tampered PATH cannot redirect its privileged helpers. Repoint them at the
  # store instead of relaxing them back to PATH lookups.
  postPatch = ''
    substituteInPlace src/blueferry/*.py src/blueferry/*/*.py \
      --replace-quiet /usr/bin/btmgmt ${bluez}/bin/btmgmt \
      --replace-quiet /usr/bin/systemctl ${systemd}/bin/systemctl \
      --replace-quiet /usr/lib/bluetooth/bluetoothd ${bluetoothd} \
      --replace-quiet /usr/lib/bluetooth/obexd ${obexd} \
      --replace-quiet /usr/share/blueferry ${placeholder "out"}/share/blueferry \
      --replace-quiet /usr/lib/systemd/system/bluetooth.service.d/blueferry.conf \
                      /etc/systemd/system/bluetooth.service.d/blueferry.conf

    substituteInPlace systemd/blueferry-set-cod \
      --replace-fail /usr/bin/btmgmt ${bluez}/bin/btmgmt
  '';

  postInstall = ''
    install -Dm644 data/io.weirdware.BlueFerry.xml \
      -t $out/share/dbus-1/interfaces
    install -Dm644 data/icons/io.weirdware.BlueFerry.svg \
      -t $out/share/icons/hicolor/scalable/apps

    # Session-bus activation for the per-user backend.
    install -d $out/share/dbus-1/services
    cat > $out/share/dbus-1/services/io.weirdware.BlueFerry.service <<EOF
    [D-BUS Service]
    Name=io.weirdware.BlueFerry
    Exec=$out/bin/blueferry run
    SystemdService=blueferry.service
    EOF

    # Consumed by the NixOS module, not by systemd directly.
    install -Dm755 systemd/blueferry-set-cod -t $out/libexec/blueferry
    install -Dm644 systemd/49-blueferry-cod.rules \
      -t $out/share/polkit-1/rules.d

    install -d $out/share/blueferry
    echo "${version}-1" > $out/share/blueferry/package-release
  ''
  + lib.optionalString withGtk ''
    install -Dm644 data/io.weirdware.BlueFerry.Gtk.desktop -t $out/share/applications
    install -Dm644 data/io.weirdware.BlueFerry.Gtk.metainfo.xml -t $out/share/metainfo
  ''
  + lib.optionalString (!withGtk) ''
    rm -rf $out/bin/blueferry-gtk $out/${python3Packages.python.sitePackages}/blueferry/ui
  ''
  + lib.optionalString withQt ''
    install -Dm644 data/io.weirdware.BlueFerry.Qt.desktop -t $out/share/applications
    install -Dm644 data/io.weirdware.BlueFerry.Qt.metainfo.xml -t $out/share/metainfo
  ''
  + lib.optionalString (!withQt) ''
    rm -rf $out/bin/blueferry-qt $out/${python3Packages.python.sitePackages}/blueferry/qt
  ''
  + lib.optionalString withQuickshell ''
    install -Dm644 data/quickshell/*.qml -t $out/share/blueferry/quickshell
    install -Dm644 data/io.weirdware.BlueFerry.Quickshell.desktop -t $out/share/applications
    install -Dm644 data/io.weirdware.BlueFerry.Quickshell.metainfo.xml -t $out/share/metainfo
    makeWrapper ${quickshell}/bin/qs $out/bin/blueferry-quickshell \
      --add-flags "-p $out/share/blueferry/quickshell"
  '';

  # The suite wants an isolated dbus-run-session and a writable HOME; the
  # import check below is what actually catches a broken closure.
  doCheck = false;

  pythonImportsCheck = [
    "blueferry"
    "blueferry.cli"
    "blueferry.daemon"
  ]
  ++ lib.optional withGtk "blueferry.ui.app";

  meta = {
    description = "iPhone messages, notifications, and contacts on Linux over Bluetooth";
    homepage = "https://github.com/erikwb/blueferry";
    license = lib.licenses.gpl2Plus;
    mainProgram = "blueferry";
    platforms = lib.platforms.linux;
  };
}
