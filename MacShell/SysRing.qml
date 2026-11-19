// (from SysMonitor) Кольцевой индикатор как в виджете «Аккумуляторы» macOS: дорожка + дуга со скруглёнными концами.
import QtQuick

Item {
    id: r
    property real size: 62
    property real value: 0          // 0..1
    property color color: "#0A84FF"
    property color track: Qt.rgba(1, 1, 1, 0.14)
    property real thickness: size * 0.11
    width: size; height: size

    property real shown: value
    Behavior on shown { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }
    onShownChanged: cv.requestPaint()
    onColorChanged: cv.requestPaint()

    Canvas {
        id: cv
        anchors.fill: parent
        antialiasing: true
        onPaint: {
            var c = getContext("2d");
            c.reset();
            var cx = width / 2, cy = height / 2, rad = (Math.min(width, height) - r.thickness) / 2;
            c.lineWidth = r.thickness;
            c.lineCap = "round";
            c.strokeStyle = r.track;
            c.beginPath(); c.arc(cx, cy, rad, 0, Math.PI * 2); c.stroke();
            var v = Math.max(0, Math.min(1, r.shown));
            if (v <= 0.002) return;
            c.strokeStyle = r.color;
            c.beginPath();
            c.arc(cx, cy, rad, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * v);
            c.stroke();
        }
    }
}
