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
    readonly property bool cfgHideWhenNotEditing: Plasmoid.configuration.hideWhenNotEditing

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

    // ------------------------------------------------ visibility in edit mode
    function updateStatus() {
        Plasmoid.status = (main.editMode || Plasmoid.userConfiguring || !main.cfgHideWhenNotEditing)
            ? PlasmaCore.Types.ActiveStatus
            : PlasmaCore.Types.HiddenStatus;
    }

    onEditModeChanged: updateStatus()
    onCfgHideWhenNotEditingChanged: updateStatus()
    Plasmoid.onUserConfiguringChanged: updateStatus()

    Component.onCompleted: {
        updateStatus();
        Qt.callLater(apply);
    }

    toolTipMainText: i18n("Panel transparency")
    toolTipSubText: main.cfgEnabled
        ? i18n("Background opacity: %1%", Math.round(main.cfgOpacity * 100))
        : i18n("Disabled")

    // Right-click action to keep the widget visible outside edit mode (so the
    // slider can be dragged) or hide it again. In edit mode the applet is
    // dragged around, so the slider only works once edit mode is left.
    PlasmaCore.Action {
        id: visibilityAction
        text: main.cfgHideWhenNotEditing ? i18n("Show widget") : i18n("Hide widget")
        icon.name: main.cfgHideWhenNotEditing ? "visibility-symbolic" : "hint"
        onTriggered: {
            Plasmoid.configuration.hideWhenNotEditing = !main.cfgHideWhenNotEditing;
            Plasmoid.configuration.writeConfig();
        }
    }

    Plasmoid.contextualActions: [visibilityAction]

    compactRepresentation: CompactRepresentation {
        panel: main
    }

    fullRepresentation: FullRepresentation {
        panel: main
    }
}
