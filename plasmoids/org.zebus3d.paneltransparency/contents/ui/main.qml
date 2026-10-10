import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: main

    // ------------------------------------------------------------ configuration
    readonly property real cfgOpacity: Plasmoid.configuration.opacity
    readonly property string cfgColorMode: Plasmoid.configuration.colorMode
    readonly property color cfgCustomColor: Plasmoid.configuration.customColor
    readonly property bool cfgBlur: Plasmoid.configuration.blur
    readonly property int cfgBlurStrength: Plasmoid.configuration.blurStrength
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

    // Background layers of the panel. Their `imagePath` contains
    // "panel-background"; the two hidden helper SVGs of Panel.qml
    // (thickPanelSvg, floatingPanelSvg) also match but are tiny, so the largest
    // one is the real background and gives the geometry.
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

    function largestItem(items) {
        // Ignore the two hidden helper SVGs of Panel.qml (thickPanelSvg,
        // floatingPanelSvg): they are tiny and would give a wrong geometry.
        let ref = null;
        for (let i = 0; i < items.length; ++i) {
            const it = items[i];
            if (it.width * it.height < 2000)
                continue;
            if (!ref || it.width * it.height > ref.width * ref.height)
                ref = it;
        }
        return ref;
    }

    // Geometry reference for our own background rectangle. The FrameSvgItem
    // objects persist even when the native background is removed
    // (NoBackground only clears their imagePath), so this stays valid.
    property var bgRefItem: null

    // Colour of the current Plasma theme panel background, used when we draw our
    // own background without the native one (blur off).
    Item {
        id: themeColorProbe
        visible: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Window
        Kirigami.Theme.inherit: false
        readonly property color bgColor: Kirigami.Theme.backgroundColor
    }

    // Custom-colour background. KSvg.FrameSvgItem has no colour property and a
    // MultiEffect only tints (modulated by luminance), so to *replace* the
    // colour we draw our own rectangle sized to the theme background geometry.
    Component {
        id: customBgComponent
        Rectangle {
            property var refItem
            x: refItem ? refItem.x : 0
            y: refItem ? refItem.y : 0
            width: refItem ? refItem.width : 0
            height: refItem ? refItem.height : 0
            // The theme draws rounded corners; match the usual Plasma radius so
            // the corners do not show square, specially on floating panels.
            radius: 6
            color: "transparent"
            opacity: 1
            z: -1
        }
    }

    property var customBg: null

    // Plasma chooses which native background layer is visible (and whether the
    // solid one is used) from the panel's own floatingness/panelOpacity, which
    // changes when a window is maximised/touching the panel. We pin that choice
    // ourselves so the transition cannot flash the solid background nor hide
    // the translucent base, not even for a frame. Only the real (large)
    // background layers are touched; the two tiny helper SVGs are left alone.
    function pinTranslucentLayers(items) {
        const el = main.panelElement;
        if (!el)
            return;
        const floating = el.floatingness !== 0;
        for (let i = 0; i < items.length; ++i) {
            const it = items[i];
            if (it.width * it.height < 2000)
                continue;
            let path = "";
            try {
                path = it.imagePath ? it.imagePath.toString() : "";
            } catch (e) {
                path = "";
            }
            if (path.indexOf("solid/") !== -1) {
                // Solid (opaque) layer: never let Plasma show it.
                it.visible = false;
                continue;
            }
            // Among the two translucent layers, the floating variant is the one
            // the other is anchored to, so it has no anchors.fill of its own.
            let floatingVariant = false;
            try {
                floatingVariant = !it.anchors.fill;
            } catch (e) {
                floatingVariant = false;
            }
            it.visible = floatingVariant ? floating : !floating;
        }
    }

    function apply() {
        const containment = Plasmoid.containment;
        if (!containment || !containment.Plasmoid)
            return;

        const items = backgroundItems();

        // The native background may already be removed (NoBackground persists in
        // the applet config across sessions), and then the real background
        // layers have no imagePath and cannot be found. Restore it for one pass
        // so we can read the real geometry, then re-apply the wanted state.
        if (!main.bgRefItem && containment.Plasmoid.backgroundHints === PlasmaCore.Types.NoBackground) {
            containment.Plasmoid.backgroundHints = PlasmaCore.Types.DefaultBackground;
            Qt.callLater(main.apply);
            return;
        }

        // Only update the reference with a real (large) background item; when the
        // native background is removed only the tiny helpers are found, and we
        // must keep the geometry we already captured.
        const ref = largestItem(items);
        if (ref)
            main.bgRefItem = ref;

        // Plasma's Adaptive opacity mode swaps the panel background to the
        // "solid" variant when a window is maximised/touching the panel
        // (Panel.qml sets panelOpacity = 1), which made the panel look
        // different. Pin panelOpacity to 0 so the translucent base is used
        // consistently and cfgOpacity stays in control. Only in Adaptive mode:
        // Translucent is already 0 and Opaque is the user's explicit choice.
        if (main.panelElement && main.panelElement.isAdaptive && main.panelElement.panelOpacity !== 0)
            main.panelElement.panelOpacity = 0;

        const transparent = main.cfgOpacity <= 0.001;
        // We draw our own background when the colour is custom, or when the blur
        // is off (KWin only blurs a panel that has a native background, so we
        // drop it and paint the colour ourselves).
        const ownBg = !transparent && (main.cfgColorMode === "custom" || !main.cfgBlur);

        // KWin turns blur and background contrast off when the panel has no
        // background (PanelView::updateMask), which is how we disable the blur.
        const hints = (transparent || (ownBg && !main.cfgBlur))
            ? PlasmaCore.Types.NoBackground
            : PlasmaCore.Types.DefaultBackground;
        if (containment.Plasmoid.backgroundHints !== hints) {
            containment.Plasmoid.backgroundHints = hints;
            Qt.callLater(main.apply);
        }

        // Native layers: hidden when we draw our own background.
        for (let i = 0; i < items.length; ++i) {
            items[i].opacity = ownBg ? 0 : main.cfgOpacity;
        }
        main.pinTranslucentLayers(items);

        if (ownBg && main.panelElement) {
            if (!main.customBg)
                main.customBg = customBgComponent.createObject(main.panelElement);
            main.customBg.refItem = main.bgRefItem;
            main.customBg.color = (main.cfgColorMode === "custom") ? main.cfgCustomColor
                                                                   : themeColorProbe.bgColor;
            main.customBg.opacity = main.cfgOpacity;
            main.customBg.visible = true;
        } else if (main.customBg) {
            main.customBg.visible = false;
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

    function setBlur(v) {
        Plasmoid.configuration.blur = v;
    }

    function setBlurStrength(v) {
        Plasmoid.configuration.blurStrength = Math.round(v);
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

    onCfgOpacityChanged: apply()
    onCfgColorModeChanged: apply()
    onCfgCustomColorChanged: apply()
    onCfgBlurChanged: apply()

    onPanelElementChanged: {
        if (main.customBg) {
            main.customBg.visible = false;
            main.customBg = null;
        }
        main.bgRefItem = null;
        apply();
    }

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
        runCommand.exec("kreadconfig6 --file kwinrc --group Effect-blur --key BlurStrength");
    }

    // Restore the native panel background if we removed it.
    Component.onDestruction: {
        const containment = Plasmoid.containment;
        if (containment && containment.Plasmoid.backgroundHints === PlasmaCore.Types.NoBackground) {
            containment.Plasmoid.backgroundHints = PlasmaCore.Types.DefaultBackground;
        }
        const el = main.panelElement;
        // Give the native layers back to Panel.qml: we broke their visible
        // bindings in pinTranslucentLayers().
        if (el) {
            const items = main.backgroundItems();
            for (let i = 0; i < items.length; ++i) {
                const it = items[i];
                if (it.width * it.height < 2000)
                    continue;
                let path = "";
                try {
                    path = it.imagePath ? it.imagePath.toString() : "";
                } catch (e) {
                    path = "";
                }
                if (path.indexOf("solid/") !== -1) {
                    it.visible = Qt.binding(function() { return el.panelOpacity !== 0; });
                    continue;
                }
                let floatingVariant = false;
                try {
                    floatingVariant = !it.anchors.fill;
                } catch (e) {
                    floatingVariant = false;
                }
                const fv = floatingVariant;
                it.visible = Qt.binding(function() {
                    const fl = el.floatingness !== 0;
                    return el.panelOpacity !== 1 && (fv ? fl : !fl);
                });
            }
        }
        if (el && el.isAdaptive)
            el.panelOpacity = el.touchingWindow ? 1 : 0;
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

    // Global KWin blur strength. KWin stores it in kwinrc [Effect-blur]
    // BlurStrength (1..15) and has no per-window strength, so this slider
    // changes the blur for every window, not only the panel.
    property bool blurSyncing: false

    RunCommand {
        id: runCommand
        onCommandFinished: (cmd, exitCode, stdout) => {
            if (cmd.startsWith("kreadconfig6") && exitCode === 0) {
                const v = parseInt(stdout.trim());
                if (!isNaN(v)) {
                    main.blurSyncing = true;
                    Plasmoid.configuration.blurStrength = v;
                    main.blurSyncing = false;
                }
            }
        }
    }

    Timer {
        id: blurTimer
        interval: 150
        onTriggered: {
            runCommand.exec("kwriteconfig6 --file kwinrc --group Effect-blur --key BlurStrength "
                + Math.round(main.cfgBlurStrength)
                + " && sleep 0.3 && qdbus6 org.kde.KWin /Effects org.kde.kwin.Effects.reconfigureEffect blur");
        }
    }

    onCfgBlurStrengthChanged: {
        if (!main.blurSyncing)
            blurTimer.restart();
    }

    compactRepresentation: CompactRepresentation {
        panel: main
    }

    fullRepresentation: FullRepresentation {
        panel: main
    }
}
