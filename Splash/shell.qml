// Экран загрузки после входа: чёрный фон, логотип Arch и полоска прогресса, как при старте мака.
// Перекрывает всё, пока поднимаются Hyprland, обои и MacShell; когда бар и док MacShell готовы —
// дозаполняет полоску, плавно гаснет и закрывается. Запускается первым в автозапуске (hyprland.lua).
//
//   qs -c Splash                   показать вручную (закроется сам, если MacShell уже запущен)
//   SPLASH_PREVIEW=1 qs -c Splash  превью: полный цикл ~5 с
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    property real progress: 0          // 0..1
    property bool ready: false
    // при автовходе обои появляются сразу, без проявления из чёрного (как у экрана блокировки)
    property real fade: (Quickshell.env("MACSHELL_AUTOLOCK") || "") !== "" ? 1 : 0
    // появление: экран входа гаснет в чёрное → заставка плавно проявляется из чёрного (без резкого скачка)
    NumberAnimation on fade { id: fadeIn; from: 0; to: 1; duration: 600; easing.type: Easing.OutCubic; running: !root.autolock }

    // фон — те же обои, что на экране блокировки/входа (MacLock берёт wallpaperPath из настроек MacShell),
    // как есть, без размытия и затемнения: вход → заставка → рабочий стол без чёрной вспышки
    property string wall: ""
    FileView {
        path: Quickshell.env("HOME") + "/.config/macbar/settings.json"
        printErrors: false
        onLoaded: { try { var p = JSON.parse(text()).wallpaperPath || ""; if (p !== "") root.wall = p; } catch (e) {} }
        onLoadFailed: root.wall = "/var/lib/macshell-greeter/users/" + Quickshell.env("USER") + "/wallpaper.png"
    }
    // SPLASH_PREVIEW=1 qs -c Splash — показать целиком, не дожидаясь MacShell (закроется через 4 с)
    readonly property bool preview: (Quickshell.env("SPLASH_PREVIEW") || "") !== ""
    // автовход (greetd initial_session): следом сразу встаёт экран блокировки MacLock на тех же обоях —
    // поэтому только обои, без логотипа и полоски, чтобы «экран загрузки» не мелькал перед блокировкой
    readonly property bool autolock: (Quickshell.env("MACSHELL_AUTOLOCK") || "") !== ""
    Timer { interval: 4000; running: root.preview; onTriggered: root.finish() }

    // пока ждём — полоска медленно ползёт к 85%, как у мака (реального процента у загрузки нет)
    NumberAnimation on progress { id: crawl; from: 0; to: 0.85; duration: 7000; easing.type: Easing.OutCubic; running: true }

    // готовность: в Hyprland появились слои бара и дока MacShell
    Process {
        id: probe
        command: ["sh", "-c", "hyprctl layers -j 2>/dev/null | grep -q '\"macbar\"' && hyprctl layers -j | grep -q '\"macdock\"'"]
        onExited: code => { if (code === 0 && !root.ready && !root.preview) settle.start(); }
    }
    Timer { interval: 250; repeat: true; running: !root.ready; onTriggered: if (!probe.running) probe.running = true }
    // дать MacShell секунду дорисовать стекло и обои, чтобы под заставкой уже было красиво
    Timer { id: settle; interval: 900; onTriggered: root.finish() }
    // запасной выход: если MacShell так и не поднялся — не держать чёрный экран вечно
    Timer { interval: 25000; running: true; onTriggered: root.finish() }

    function finish() {
        if (ready) return;
        ready = true;
        crawl.stop();
        done.start();
    }
    SequentialAnimation {
        id: done
        NumberAnimation { target: root; property: "progress"; to: 1; duration: 350; easing.type: Easing.OutCubic }
        PauseAnimation { duration: 150 }
        // та же кривая выхода, что у MacLock (420 мс InOutCubic)
        NumberAnimation { target: root; property: "fade"; to: 0; duration: 420; easing.type: Easing.InOutCubic }
        ScriptAction { script: Qt.quit() }
    }

    Variants {
        model: Quickshell.screens
        PanelWindow {
            required property var modelData
            screen: modelData
            anchors { top: true; bottom: true; left: true; right: true }
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.namespace: "splash"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: root.fade

                // обои проявляются из чёрного после декодирования (4K PNG ~0.5 с), а не «впрыгивают»;
                // размер декодирования как у MacLock — при переходе в блокировку картинка совпадает 1:1
                Image {
                    id: wallImg
                    anchors.fill: parent
                    source: root.wall !== "" ? "file://" + root.wall : ""
                    fillMode: Image.PreserveAspectCrop
                    sourceSize.width: Math.max(1, Math.min(width * 1.15, 2560))
                    asynchronous: true
                    smooth: true
                    opacity: status === Image.Ready ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
                }

                Image {
                    id: logo
                    visible: !root.autolock
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -50
                    source: Qt.resolvedUrl("arch.svg")
                    sourceSize: Qt.size(288, 288)
                    width: 144; height: 144
                    smooth: true
                }

                // полоска прогресса
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: logo.bottom
                    anchors.topMargin: 72
                    width: 300; height: 7; radius: 3.5
                    visible: !root.autolock
                    color: Qt.rgba(1, 1, 1, 0.22)
                    Rectangle {
                        width: Math.max(height, parent.width * root.progress)
                        height: parent.height; radius: parent.radius
                        color: "white"
                    }
                }
            }
        }
    }
}
