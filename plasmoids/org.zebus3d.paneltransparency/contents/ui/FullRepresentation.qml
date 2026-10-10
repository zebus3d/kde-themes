import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kquickcontrols as KQC

Item {
    id: full

    property var panel

    implicitWidth: Kirigami.Units.gridUnit * 18
    implicitHeight: layout.implicitHeight + Kirigami.Units.largeSpacing * 2

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.smallSpacing

        PlasmaComponents3.Label {
            Layout.fillWidth: true
            text: i18n("Panel background")
            font.bold: true
        }

        PlasmaComponents3.CheckBox {
            Layout.fillWidth: true
            text: i18n("Enable custom panel background")
            checked: full.panel ? full.panel.cfgEnabled : true
            onToggled: if (full.panel) full.panel.setEnabled(checked)
        }

        PlasmaComponents3.CheckBox {
            Layout.fillWidth: true
            text: i18n("Show the opacity slider in the panel")
            checked: full.panel ? full.panel.cfgSliderVisible : false
            onToggled: if (full.panel) full.panel.setSliderVisible(checked)
        }

        PlasmaComponents3.Slider {
            id: opacitySlider
            Layout.fillWidth: true
            from: 0
            to: 1
            stepSize: 0.05
            enabled: full.panel ? full.panel.cfgEnabled : true
            value: full.panel ? full.panel.cfgOpacity : 1
            onValueChanged: if (full.panel) full.panel.setOpacity(value)
            onPressedChanged: if (!pressed && full.panel) full.panel.saveConfig()
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents3.Label {
                text: i18n("Color:")
            }

            PlasmaComponents3.ComboBox {
                id: colorModeBox
                Layout.fillWidth: true
                enabled: full.panel ? full.panel.cfgEnabled : true
                model: [i18n("Theme color"), i18n("Custom color")]
                currentIndex: (full.panel && full.panel.cfgColorMode === "custom") ? 1 : 0
                onActivated: if (full.panel) full.panel.setColorMode(currentIndex === 1 ? "custom" : "theme")
            }

            KQC.ColorButton {
                enabled: full.panel && full.panel.cfgEnabled && full.panel.cfgColorMode === "custom"
                showAlphaChannel: false
                color: full.panel ? full.panel.cfgCustomColor : "transparent"
                onAccepted: (c) => { if (full.panel) full.panel.setCustomColor(c); }
            }
        }

        PlasmaComponents3.Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            opacity: 0.7
            font: Kirigami.Theme.smallFont
            text: i18n("Controls the panel this widget is placed in. Right-click the widget and choose Configure for all options.")
        }
    }
}
