// Contents of the "System" desktop widget (the former standalone SysMonitor), drawn on a CardWidget.
//   small  – title + 2 × 2 rings (CPU / Memory / GPU / Disk)
//   medium – title + the four rings with temperature / amount underneath
//   large  – everything: rings, CPU graph, network graph, SSD / VRAM / swap / uptime line
// Data comes from MacWidgets (sysstats.py, one JSON line a second): host.sysData, host.sysCpuHist, host.sysDownHist, host.sysUpHist.
// Double click opens Mission Center.
import QtQuick
import Quickshell
import "I18n.js" as I18n
import "Fonts.js" as Fonts

Item {
    id: sc
    property var host: null
    readonly property var ctx: parent ? parent.ctx : null
    readonly property string sz: ctx ? ctx.size : "l"
    readonly property bool dark: ctx ? ctx.dark : true
    readonly property color fg: ctx ? ctx.fg : "white"
    readonly property color fgSub: ctx ? ctx.fg2 : Qt.rgba(1, 1, 1, 0.55)
    readonly property color line: dark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.10)
    readonly property string fam: host ? host.fontFamily : "Open Runde"
    readonly property var d: host ? host.sysData : ({})

    readonly property color cBlue: "#0A84FF"
    readonly property color cGreen: dark ? "#30D158" : "#28B44C"
    readonly property color cPurple: "#BF5AF2"
    readonly property color cOrange: "#FF9F0A"
    readonly property color cRed: "#FF453A"
    readonly property color cTeal: dark ? "#64D2FF" : "#2AA7E0"

    function bytes(b) {
        var u = [I18n.tr("B"), I18n.tr("KB"), I18n.tr("MB"), I18n.tr("GB"), I18n.tr("TB")], i = 0;
        b = b || 0;
        while (b >= 1024 && i < u.length - 1) { b /= 1024; i++; }
        return (i < 2 ? Math.round(b) : b.toFixed(b < 10 ? 1 : 0)) + " " + u[i];
    }
    function speed(b) { return bytes(b) + I18n.tr("/s"); }
    function uptime(sec) {
        var h = Math.floor(sec / 3600), m = Math.floor(sec % 3600 / 60);
        return h > 23 ? Math.floor(h / 24) + " " + I18n.tr("d") + " " + (h % 24) + " " + I18n.tr("h")
             : (h > 0 ? h + " " + I18n.tr("h") + " " + m + " " + I18n.tr("min") : m + " " + I18n.tr("min"));
    }
    function level(p, base) { return p >= 90 ? cRed : base; }
    function ringVal(i) { return i === 0 ? (d.cpu || 0) : i === 1 ? (d.ram || 0) : i === 2 ? Math.max(0, d.gpu || 0) : (d.disk || 0); }
    function ringSub(i) { return i === 0 ? (d.tCpu || 0) + "°" : i === 1 ? bytes(d.ramUsed) : i === 2 ? (d.tGpu || 0) + "°" : bytes(d.diskFree); }
    readonly property var rings: [
        { label: I18n.tr("CPU"),    c: cBlue },
        { label: I18n.tr("Memory"), c: cGreen },
        { label: "GPU",             c: cPurple },
        { label: I18n.tr("Disk"),   c: cOrange }
    ]

    MouseArea {
        anchors.fill: parent
        enabled: host && !host.editing
        onDoubleClicked: Quickshell.execDetached(["missioncenter"])
    }

    // ── title + battery ──
    Item {
        id: head
        width: parent.width
        height: sc.sz === "s" ? 16 : 20
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: I18n.tr("System Overview")
            color: sc.fg
            font.family: Fonts.forWeight(Font.DemiBold, sc.fam)
            font.pixelSize: sc.sz === "s" ? 13 : 15
            font.weight: Font.DemiBold
        }
        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: sc.d.bat === undefined ? "" : "\u{F0079} " + sc.d.bat + "%"
                  + (sc.sz === "s" ? "" : (sc.d.batStatus === "Charging" ? " · " + I18n.tr("charging")
                                          : (sc.d.batW !== undefined ? " · " + sc.d.batW + " " + I18n.tr("W") : "")))
            color: sc.fgSub
            font.family: sc.fam
            font.pixelSize: sc.sz === "s" ? 11 : 12
        }
    }

    // ── small: 2 × 2 rings ──
    Grid {
        visible: sc.sz === "s"
        y: head.height + 6
        width: parent.width
        columns: 2
        rowSpacing: 6
        Repeater {
            model: 4
            Item {
                required property int index
                readonly property real v: sc.ringVal(index)
                width: sc.width / 2
                height: 51
                SysRing {
                    id: rs
                    anchors.horizontalCenter: parent.horizontalCenter
                    size: 36
                    value: parent.v / 100
                    color: sc.level(parent.v, sc.rings[parent.index].c)
                    track: sc.line
                    Text {
                        anchors.centerIn: parent
                        text: Math.round(parent.parent.v)
                        color: sc.fg
                        font.family: Fonts.forWeight(Font.DemiBold, sc.fam)
                        font.pixelSize: 11; font.weight: Font.DemiBold
                        font.features: { "tnum": 1 }
                    }
                }
                Text {
                    anchors.top: rs.bottom; anchors.topMargin: 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: sc.rings[parent.index].label
                    color: sc.fgSub
                    font.family: sc.fam; font.pixelSize: 10; font.weight: Font.Medium
                }
            }
        }
    }

    // ── medium / large: the rings row, then (large) graphs ──
    Column {
        id: mainCol
        visible: sc.sz !== "s"
        y: head.height + (sc.sz === "m" ? 12 : 12)
        width: parent.width
        spacing: 12
        // large: the two graphs share whatever height is left, so the card has no empty chin
        readonly property real graphH: Math.max(36, (sc.height - y - 96 - 2 * 24 - footer.implicitHeight - 4 * spacing) / 2)

        Row {
            width: parent.width
            readonly property real cell: width / 4
            Repeater {
                model: 4
                Item {
                    required property int index
                    readonly property real v: sc.ringVal(index)
                    width: parent.cell
                    height: 96
                    SysRing {
                        id: rm
                        anchors.horizontalCenter: parent.horizontalCenter
                        size: 60
                        value: parent.v / 100
                        color: sc.level(parent.v, sc.rings[parent.index].c)
                        track: sc.line
                        Text {
                            anchors.centerIn: parent
                            text: Math.round(parent.parent.v) + "%"
                            color: sc.fg
                            font.family: Fonts.forWeight(Font.DemiBold, sc.fam)
                            font.pixelSize: 14; font.weight: Font.DemiBold
                            font.features: { "tnum": 1 }
                        }
                    }
                    Text {
                        anchors.top: rm.bottom; anchors.topMargin: 5
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: sc.rings[parent.index].label
                        color: sc.fg
                        font.family: sc.fam; font.pixelSize: 12; font.weight: Font.Medium
                    }
                    Text {
                        anchors.top: rm.bottom; anchors.topMargin: 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: sc.ringSub(parent.index)
                        color: sc.fgSub
                        font.family: sc.fam; font.pixelSize: 11
                    }
                }
            }
        }

        SysGraph {
            visible: sc.sz === "l"
            width: parent.width
            title: I18n.tr("Processor")
            value: Math.round(sc.d.cpu || 0) + "%"
            detail: (sc.d.ghz || 0) + " " + I18n.tr("GHz") + " · " + I18n.tr("load") + " " + (sc.d.load || "0")
            graphH: mainCol.graphH
            series: sc.host && sc.sz === "l" ? [ { data: sc.host.sysCpuHist, color: sc.cBlue, max: 100 } ] : []
            fam: sc.fam; fg: sc.fg; fgSub: sc.fgSub; line: sc.line; s: 1
        }

        SysGraph {
            visible: sc.sz === "l"
            width: parent.width
            readonly property real netMax: sc.host ? Math.max(64 * 1024, Math.max.apply(null, sc.host.sysDownHist.concat(sc.host.sysUpHist, [0]))) : 1
            title: I18n.tr("Network")
            value: "↓ " + sc.speed(sc.d.down)
            detail: "↑ " + sc.speed(sc.d.up) + (sc.d.iface ? " · " + sc.d.iface : "")
            graphH: mainCol.graphH
            series: sc.host && sc.sz === "l" ? [ { data: sc.host.sysDownHist, color: sc.cTeal, max: netMax },
                                                 { data: sc.host.sysUpHist, color: sc.cGreen, max: netMax } ] : []
            fam: sc.fam; fg: sc.fg; fgSub: sc.fgSub; line: sc.line; s: 1
        }

        Text {
            id: footer
            visible: sc.sz === "l"
            width: parent.width
            text: "SSD " + (sc.d.tSsd || 0) + "° · " + I18n.tr("VRAM") + " " + sc.bytes(sc.d.vramUsed)
                  + " · swap " + sc.bytes(sc.d.swap)
                  + (sc.d.uptime !== undefined ? " · " + sc.uptime(sc.d.uptime) : "")
            color: sc.fgSub
            elide: Text.ElideRight
            font.family: sc.fam; font.pixelSize: 11
        }
    }
}
