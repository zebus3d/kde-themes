import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

Item {
    id: root

    property var panel

    // While the panel is being edited the applet is dragged around, so a
    // slider there cannot be used. Show a plain icon instead, and the actual
    // slider only outside edit mode (where it is interactive).
    readonly property bool editing: panel ? panel.editMode : false

    implicitWidth: editing ? icon.implicitWidth : slider.width
    implicitHeight: editing ? icon.implicitHeight : slider.implicitHeight
    Layout.preferredWidth: implicitWidth
    Layout.alignment: Qt.AlignVCenter

    PlasmaComponents3.Slider {
        id: slider
        visible: !root.editing
        anchors.centerIn: parent
        width: Kirigami.Units.gridUnit * 6
        from: 0
        to: 1
        stepSize: 0.05
        enabled: root.panel ? root.panel.cfgEnabled : true
        value: root.panel ? root.panel.cfgOpacity : 1.0
        Accessible.name: i18n("Panel background opacity")

        onValueChanged: {
            if (root.panel)
                root.panel.setOpacity(value);
        }

        onPressedChanged: {
            if (!pressed && root.panel)
                root.panel.saveConfig();
        }

        Connections {
            target: root.panel
            function onCfgOpacityChanged() {
                if (!slider.pressed && slider.value !== root.panel.cfgOpacity)
                    slider.value = root.panel.cfgOpacity;
            }
        }
    }

    Kirigami.Icon {
        id: icon
        visible: root.editing
        anchors.centerIn: parent
        source: "preferences-desktop-color"
        implicitWidth: Kirigami.Units.iconSizes.smallMedium
        implicitHeight: Kirigami.Units.iconSizes.smallMedium
    }
}
