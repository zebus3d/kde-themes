import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQControls

Kirigami.FormLayout {
    id: page

    property alias cfg_opacity: opacitySlider.value
    property alias cfg_customColor: colorButton.color
    property alias cfg_blur: blurBox.checked
    property alias cfg_blurStrength: blurStrengthSlider.value
    property alias cfg_sliderVisible: sliderVisibleBox.checked
    property string cfg_colorMode: "theme"

    QQC2.Slider {
        id: opacitySlider
        Kirigami.FormData.label: i18n("Opacity:")
        from: 0
        to: 1
        QQC2.ToolTip.text: i18n("0% is fully transparent, 100% is solid.")
        QQC2.ToolTip.visible: hovered
    }

    QQC2.ComboBox {
        id: colorModeBox
        Kirigami.FormData.label: i18n("Color:")
        model: [i18n("Theme color"), i18n("Custom color")]
        currentIndex: page.cfg_colorMode === "custom" ? 1 : 0
        onActivated: page.cfg_colorMode = (currentIndex === 1 ? "custom" : "theme")
        QQC2.ToolTip.text: i18n("Use the color of the current Plasma style, or pick your own.")
        QQC2.ToolTip.visible: hovered
    }

    KQControls.ColorButton {
        id: colorButton
        Kirigami.FormData.label: i18n("Custom color:")
        showAlphaChannel: false
        enabled: page.cfg_colorMode === "custom"
        QQC2.ToolTip.text: i18n("Background color used when Color is set to Custom color.")
        QQC2.ToolTip.visible: hovered
    }

    QQC2.CheckBox {
        id: blurBox
        text: i18n("Blur behind the panel")
        QQC2.ToolTip.text: i18n("KWin only blurs a panel that has a background, so turning this off paints the color without blur.")
        QQC2.ToolTip.visible: hovered
    }

    QQC2.Slider {
        id: blurStrengthSlider
        Kirigami.FormData.label: i18n("Blur strength:")
        from: 1
        to: 15
        enabled: blurBox.checked
        QQC2.ToolTip.text: i18n("Strength of the global KWin blur effect. Affects every window, not only the panel.")
        QQC2.ToolTip.visible: hovered
    }

    QQC2.CheckBox {
        id: sliderVisibleBox
        text: i18n("Show the opacity slider in the panel")
        QQC2.ToolTip.text: i18n("When off, the widget collapses to a small handle you can still right-click.")
        QQC2.ToolTip.visible: hovered
    }
}
