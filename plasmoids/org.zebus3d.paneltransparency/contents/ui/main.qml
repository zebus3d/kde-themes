import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: main

    // ------------------------------------------------------------ configuration
    readonly property bool cfgEnabled: Plasmoid.configuration.enabled
    readonly property real cfgOpacity: Plasmoid.configuration.opacity
    readonly property string cfgColorMode: Plasmoid.configuration.colorMode
    readonly property color cfgCustomColor: Plasmoid.configuration.customColor
    readonly property bool cfgSliderVisible: Plasmoid.configuration.sliderVisible

    readonly property bool editMode: {
        const containment = Plasmoid.containment;
        if (!containment)
            return false;
        const corona = containment.corona;
        return corona ? corona.editMode : false;
    }

    // -------------------------------------------------- the Panel.qml root item
    // Walk up the item tree until we find the Panel view: it is the first
    // ancestor exposing a "floating" property (Panel.qml root).
    readonly property var panelElement: {
        let candidate = main.parent;
        while (candidate) {
            if (candidate.hasOwnProperty("floating"))
                return candidate;
            candidate = candidate.parent;
        }
        return null;
    }

    // The four KSvg.FrameSvgItem layers that draw the panel background
    // (translucent/opaque, floating/not). Their `imagePath` contains
    // "panel-background".
    function backgroundItems() {
        const el = main.panelElement;
        let result = [];
        if (!el)
            return result;
        const children = el.children;
        for (let i = 0; i < children.length; ++i) {
            const child = children[i];
            let path;
            try {
                path = child.imagePath;
            } catch (e) {
                path = undefined;
            }
            if (path && path.toString().indexOf("panel-background") !== -1)
                result.push(child);
        }
        return result;
    }

    // One MultiEffect per background item, tinting the theme's artwork to the
    // custom colour while keeping its shape, border and blur mask.
    property var tintEffects: new Map()

    Component {
        id: tintComponent
        MultiEffect {
            colorization: 1.0
            colorizationColor: main.cfgCustomColor
        }
    }

    function apply() {
        const items = backgroundItems();
        const alpha = main.cfgEnabled ? main.cfgOpacity : 1.0;
        const custom = main.cfgEnabled && main.cfgColorMode === "custom";
        for (let i = 0; i < items.length; ++i) {
            const item = items[i];
            item.opacity = alpha;
            if (custom) {
                if (!main.tintEffects.has(item)) {
                    main.tintEffects.set(item, tintComponent.createObject(item));
                }
                item.layer.effect = main.tintEffects.get(item);
                item.layer.enabled = true;
            } else {
                item.layer.enabled = false;
                item.layer.effect = null;
            }
        }
    }

    function setOpacity(v) {
        Plasmoid.configuration.opacity = v;
    }

    function setColorMode(mode) {
        Plasmoid.configuration.colorMode = mode;
    }

    function setCustomColor(c) {
        Plasmoid.configuration.customColor = c;
    }

    function setEnabled(v) {
        Plasmoid.configuration.enabled = v;
    }

    function setSliderVisible(v) {
        Plasmoid.configuration.sliderVisible = v;
    }

    function toggleSlider() {
        Plasmoid.configuration.sliderVisible = !main.cfgSliderVisible;
        Plasmoid.configuration.writeConfig();
    }

    function saveConfig() {
        Plasmoid.configuration.writeConfig();
    }

    onCfgEnabledChanged: apply()
    onCfgOpacityChanged: apply()
    onCfgColorModeChanged: apply()
    onCfgCustomColorChanged: apply()
    onPanelElementChanged: apply()

    Connections {
        target: main.panelElement
        function onFloatingnessChanged() {
            main.apply();
        }
        function onPanelOpacityChanged() {
            main.apply();
        }
    }

    // The widget is always present in the panel (never HiddenStatus): when the
    // slider is off it collapses to a small handle so it can be right-clicked
    // at any time and "feels" always there.
    Component.onCompleted: {
        Plasmoid.status = PlasmaCore.Types.ActiveStatus;
        Qt.callLater(apply);
    }

    toolTipMainText: i18n("Panel transparency")
    toolTipSubText: main.cfgEnabled
        ? i18n("Background opacity: %1%", Math.round(main.cfgOpacity * 100))
        : i18n("Disabled")

    // Right-click action: show or hide the opacity slider. The slider is only
    // interactive outside panel edit mode, where the panel is not capturing
    // drags to move applets.
    PlasmaCore.Action {
        id: sliderAction
        text: main.cfgSliderVisible ? i18n("Hide slider") : i18n("Show slider")
        icon.name: main.cfgSliderVisible ? "visibility-symbolic" : "hint"
        onTriggered: main.toggleSlider()
    }

    Plasmoid.contextualActions: [sliderAction]

    compactRepresentation: CompactRepresentation {
        panel: main
    }

    fullRepresentation: FullRepresentation {
        panel: main
    }
}
