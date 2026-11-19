// Строка с заголовком и плавным графиком истории (заливка градиентом, как в «Акциях» macOS).
import QtQuick

Column {
    id: g
    property string title: ""
    property string value: ""
    property string detail: ""
    property var series: []          // [{ data: [..], color, max }]
    property string fam: "Inter"
    property color fg: "white"
    property color fgSub: "gray"
    property color line: Qt.rgba(1, 1, 1, 0.14)
    property real s: 1
    property real graphH: 40          // height of the plot itself (the owner can stretch it to fill the card)
    spacing: 6 * s

    // новая точка приходит раз в секунду: график не прыгает, а плавно сдвигается на шаг за эту секунду
    property real phase: 0
    onSeriesChanged: { slide.restart(); }
    NumberAnimation on phase { id: slide; from: 1; to: 0; duration: 1000; running: false }
    onPhaseChanged: cv.requestPaint()

    Item {
        width: g.width; height: 18 * g.s
        Row {
            spacing: 8 * g.s
            anchors.verticalCenter: parent.verticalCenter
            Text { text: g.title; color: g.fg; font.family: g.fam; font.pixelSize: 13 * g.s; font.weight: Font.Medium }
            Text { text: g.value; color: g.fg; font.family: g.fam; font.pixelSize: 13 * g.s; font.weight: Font.DemiBold; font.features: { "tnum": 1 } }
        }
        Text {
            anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
            text: g.detail; color: g.fgSub
            font.family: g.fam; font.pixelSize: 11.5 * g.s; font.features: { "tnum": 1 }
        }
    }

    Canvas {
        id: cv
        width: g.width; height: g.graphH * g.s
        antialiasing: true
        renderTarget: Canvas.FramebufferObject
        renderStrategy: Canvas.Cooperative
        clip: true
        onPaint: {
            var c = getContext("2d");
            c.reset();
            var w = width, h = height;
            // сетка
            c.strokeStyle = g.line; c.lineWidth = 1;
            c.beginPath(); c.moveTo(0, h - 0.5); c.lineTo(w, h - 0.5); c.stroke();
            for (var si = 0; si < g.series.length; si++) {
                var sr = g.series[si], data = sr.data || [], n = data.length;
                if (n < 2) continue;
                var max = sr.max || Math.max.apply(null, data) || 1;
                var pts = [];
                // последняя точка — у правого края; пока идёт сдвиг, весь график смещён вправо на долю шага
                var step = w / (n - 2);
                for (var i = 0; i < n; i++)
                    pts.push([(i - 1 + g.phase) * step, h - 2 - Math.min(1, data[i] / max) * (h - 6)]);
                // плавная кривая
                function path() {
                    c.moveTo(pts[0][0], pts[0][1]);
                    for (var k = 1; k < pts.length; k++) {
                        var mx = (pts[k - 1][0] + pts[k][0]) / 2;
                        c.bezierCurveTo(mx, pts[k - 1][1], mx, pts[k][1], pts[k][0], pts[k][1]);
                    }
                }
                var col = Qt.color(sr.color);
                var grad = c.createLinearGradient(0, 0, 0, h);
                grad.addColorStop(0, Qt.rgba(col.r, col.g, col.b, si === 0 ? 0.38 : 0.22));
                grad.addColorStop(1, Qt.rgba(col.r, col.g, col.b, 0.0));
                c.beginPath(); path(); c.lineTo(w, h); c.lineTo(0, h); c.closePath();
                c.fillStyle = grad; c.fill();
                c.beginPath(); path();
                c.strokeStyle = sr.color; c.lineWidth = 1.6; c.lineJoin = "round"; c.stroke();
            }
        }
    }
}
