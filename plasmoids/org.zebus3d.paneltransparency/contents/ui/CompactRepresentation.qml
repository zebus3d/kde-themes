import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

Item {
    id: root

    property var panel

    // The slider is only interactive outside panel edit mode (there the panel
    // captures drags to move applets), and only when explicitly shown.
    readonly property bool showSlider: panel ? (panel.cfgSliderVisible && !panel.editMode) : false

    implicitWidth: showSlider ? Kirigami.Units.gridUnit * 6 : Kirigami.Units.gridUnit * 0.5
    implicitHeight: showSlider ? slider.implicitHeight : Kirigami.Units.iconSizes.small
    Layout.preferredWidth: implicitWidth
    Layout.alignment: Qt.AlignVCenter

    PlasmaComponents3.Slider {
        id: slider
        visible: root.showSlider
        anchors.centerIn: parent
        width: Kirigami.Units.gridUnit * 6
        from: 0
        to: 1
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

    // Collapsed state: a thin, faint grip. The widget keeps its slot in the
    // panel so it stays reachable (right-click / click) without being noticed.
    Rectangle {
        visible: !root.showSlider
        anchors.centerIn: parent
        width: 2
        height: Kirigami.Units.iconSizes.small
        radius: 1
        color: Kirigami.Theme.textColor
        opacity: 0.3
    }
}
