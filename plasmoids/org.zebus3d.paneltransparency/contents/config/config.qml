import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kquickcontrols as KQC

Kirigami.ScrollablePage {
    id: page

    property alias cfg_enabled: enabledBox.checked
    property alias cfg_opacity: opacitySlider.value
    property alias cfg_customColor: colorButton.color
    property alias cfg_hideWhenNotEditing: hideBox.checked
    property string cfg_colorMode: "theme"

    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing

        PlasmaComponents3.CheckBox {
            id: enabledBox
            text: i18n("Enable custom panel background")
        }

        Kirigami.FormLayout {
            PlasmaComponents3.Slider {
                id: opacitySlider
                Kirigami.FormData.label: i18n("Opacity:")
                from: 0
                to: 1
                stepSize: 0.05
            }

            PlasmaComponents3.ComboBox {
                id: colorModeBox
                Kirigami.FormData.label: i18n("Color:")
                model: [i18n("Theme color"), i18n("Custom color")]
                currentIndex: page.cfg_colorMode === "custom" ? 1 : 0
                onActivated: page.cfg_colorMode = (currentIndex === 1 ? "custom" : "theme")
            }

            KQC.ColorButton {
                id: colorButton
                Kirigami.FormData.label: i18n("Custom color:")
                showAlphaChannel: false
                enabled: enabledBox.checked && page.cfg_colorMode === "custom"
            }

            PlasmaComponents3.CheckBox {
                id: hideBox
                Kirigami.FormData.label: i18n("Visibility:")
                text: i18n("Only show the widget while editing the panel")
            }
        }

        PlasmaComponents3.Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            opacity: 0.7
            font: Kirigami.Theme.smallFont
            text: i18n("The opacity control is available directly in the panel while it is in edit mode. Changes apply to the panel this widget is placed in.")
        }
    }
}
