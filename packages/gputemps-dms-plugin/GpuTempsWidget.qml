import QtQuick
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    layerNamespacePlugin: "gpu-temps"

    // Temperature properties (default to -1 = not yet loaded)
    property int coreTemp: -1
    property int junctionTemp: -1
    property int vramTemp: -1

    // Thresholds matching gputemps.c
    readonly property int coreWarn: 70
    readonly property int coreDanger: 85
    readonly property int junctionWarn: 80
    readonly property int junctionDanger: 95
    readonly property int vramWarn: 80
    readonly property int vramDanger: 95

    // Polling interval in ms
    readonly property int pollInterval: 3000

    function tempColor(temp, warn, danger) {
        if (temp >= danger) return Theme.tempDanger || "#ff4444";
        if (temp >= warn)   return Theme.tempWarning || "#ffaa00";
        return Theme.widgetTextColor || "#ffffff";
    }

    function tempText(temp) {
        if (temp < 0) return "--°";
        return temp + "°";
    }

    // Run gputemps periodically
    Timer {
        interval: root.pollInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: gpuTempsProcess.running = true
    }

    Process {
        id: gpuTempsProcess
        command: ["gputemps", "--json", "--once"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim()) {
                    try {
                        var data = JSON.parse(text.trim());
                        if (data.gpus && data.gpus.length > 0) {
                            var gpu = data.gpus[0];
                            root.coreTemp = gpu.core || 0;
                            root.junctionTemp = gpu.junction || 0;
                            root.vramTemp = gpu.vram || 0;
                        }
                    } catch (e) {
                        console.warn("gpuTemps: failed to parse JSON:", e);
                    }
                }
            }
        }
        onExited: exitCode => {
            if (exitCode !== 0) {
                console.warn("gpuTemps: process exited with code", exitCode);
            }
        }
    }

    // Horizontal bar layout: icon + "42° 55° 48°"
    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            DankIcon {
                name: "device_thermostat"
                size: root.iconSize
                color: {
                    // Icon color reflects the hottest reading
                    var maxTemp = Math.max(root.coreTemp, root.junctionTemp, root.vramTemp);
                    if (maxTemp >= root.coreDanger) return Theme.tempDanger || "#ff4444";
                    if (maxTemp >= root.coreWarn)   return Theme.tempWarning || "#ffaa00";
                    return Theme.widgetIconColor || "#ffffff";
                }
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: root.tempText(root.coreTemp)
                font.pixelSize: Theme.fontSizeSmall
                color: root.tempColor(root.coreTemp, root.coreWarn, root.coreDanger)
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: root.tempText(root.junctionTemp)
                font.pixelSize: Theme.fontSizeSmall
                color: root.tempColor(root.junctionTemp, root.junctionWarn, root.junctionDanger)
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: root.tempText(root.vramTemp)
                font.pixelSize: Theme.fontSizeSmall
                color: root.tempColor(root.vramTemp, root.vramWarn, root.vramDanger)
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // Vertical bar layout: icon + stacked temps
    verticalBarPill: Component {
        Column {
            spacing: 1

            DankIcon {
                name: "device_thermostat"
                size: root.iconSize
                color: {
                    var maxTemp = Math.max(root.coreTemp, root.junctionTemp, root.vramTemp);
                    if (maxTemp >= root.coreDanger) return Theme.tempDanger || "#ff4444";
                    if (maxTemp >= root.coreWarn)   return Theme.tempWarning || "#ffaa00";
                    return Theme.widgetIconColor || "#ffffff";
                }
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                text: root.tempText(root.coreTemp)
                font.pixelSize: Theme.fontSizeSmall
                color: root.tempColor(root.coreTemp, root.coreWarn, root.coreDanger)
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                text: root.tempText(root.junctionTemp)
                font.pixelSize: Theme.fontSizeSmall
                color: root.tempColor(root.junctionTemp, root.junctionWarn, root.junctionDanger)
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                text: root.tempText(root.vramTemp)
                font.pixelSize: Theme.fontSizeSmall
                color: root.tempColor(root.vramTemp, root.vramWarn, root.vramDanger)
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
