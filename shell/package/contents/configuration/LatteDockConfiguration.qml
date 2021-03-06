/*
*  Copyright 2016  Smith AR <audoban@openmailbox.org>
*                  Michail Vourlakos <mvourlakos@gmail.com>
*
*  This file is part of Latte-Dock
*
*  Latte-Dock is free software; you can redistribute it and/or
*  modify it under the terms of the GNU General Public License as
*  published by the Free Software Foundation; either version 2 of
*  the License, or (at your option) any later version.
*
*  Latte-Dock is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls 2.12 as QtQuickControls212
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Window 2.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import QtQuick.Controls.Styles.Plasma 2.0 as Styles

import org.kde.kquickcontrolsaddons 2.0 as KQuickControlAddons

import org.kde.latte.core 0.2 as LatteCore
import org.kde.latte.components 1.0 as LatteComponents

import "pages" as Pages
import "../controls" as LatteExtraControls

Loader {
    active: plasmoid && plasmoid.configuration && latteView

    sourceComponent: FocusScope {
        id: dialog
        width: appliedWidth
        height: appliedHeight

        readonly property bool basicLevel: !advancedLevel
        readonly property bool advancedLevel: universalSettings.inAdvancedModeForEditSettings

        readonly property bool inConfigureAppletsMode: plasmoid.configuration.inConfigureAppletsMode || !LatteCore.WindowSystem.compositingActive

        readonly property bool kirigamiLibraryIsFound: LatteCore.Environment.frameworksVersion >= LatteCore.Environment.makeVersion(5,69,0)

        //! max size based on screen resolution
        //!    TODO: if we can access availableScreenGeometry.height this can be improved, currently
        //!    we use 100px. or 50px. in order to give space for othe views to be shown and to have also
        //!    some space around the settings window
        property int maxHeight: plasmoid.formFactor === PlasmaCore.Types.Horizontal ?
                                    viewConfig.availableScreenGeometry.height - (latteView.editThickness - latteView.maxNormalThickness) - units.largeSpacing :
                                    viewConfig.availableScreenGeometry.height - 2 * units.largeSpacing

        property int maxWidth: 0.6 * latteView.screenGeometry.width

        //! propose size based on font size
        property int proposedWidth: 0.82 * proposedHeight + units.smallSpacing * 2
        property int proposedHeight: 36 * theme.mSize(theme.defaultFont).height

        //! chosen size to be applied, if the user has set or not a different scale for the settings window
        property int chosenWidth: userScaleWidth !== 1 ? userScaleWidth * proposedWidth : proposedWidth
        property int chosenHeight: userScaleHeight !== 1 ? userScaleHeight * heightLevel * proposedHeight : heightLevel * proposedHeight

        readonly property int optionsWidth: appliedWidth - units.smallSpacing * 10

        //! user set scales based on its preference, e.g. 96% of the proposed size
        property real userScaleWidth: 1
        property real userScaleHeight: 1

        readonly property real heightLevel: (dialog.advancedLevel ? 100 : 1) //in order to use all available space

        onHeightChanged: viewConfig.syncGeometry();

        //! applied size in order to not be out of boundaries
        //! width can be between 200px - maxWidth
        //! height can be between 400px - maxHeight
        property int appliedWidth: Math.min(maxWidth, Math.max(200, chosenWidth))
        property int appliedHeight: universalSettings.inAdvancedModeForEditSettings ? maxHeight : Math.min(maxHeight, Math.max(400, chosenHeight))

        Layout.minimumWidth: width
        Layout.minimumHeight: height
        LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
        LayoutMirroring.childrenInherit: true

        readonly property bool viewIsPanel: latteView.type === LatteCore.Types.PanelView

        property bool panelIsVertical: plasmoid.formFactor === PlasmaCore.Types.Vertical
        property int subGroupSpacing: units.largeSpacing + units.smallSpacing * 1.5

        property color bC: theme.backgroundColor
        property color tC: theme.textColor
        property color transparentBackgroundColor: Qt.rgba(bC.r, bC.g, bC.b, 0.7)
        property color borderColor: Qt.rgba(tC.r, tC.g, tC.b, 0.12)

        readonly property Item currentPage: pagesStackView.currentItem

        onAdvancedLevelChanged: {
            //! switch to appearancePage when effectsPage becomes hidden because
            //! advancedLevel was disabled by the user
            if (!advancedLevel && tabBar.currentTab === effectsTabBtn) {
                tabBar.currentTab = appearanceTabBtn;
            }
        }

        Component.onCompleted: {
            updateScales();
        }

        Connections {
            target: latteView.positioner
            onCurrentScreenNameChanged: dialog.updateScales();
        }

        function updateScales() {
            userScaleWidth = universalSettings.screenWidthScale(latteView.positioner.currentScreenName);
            userScaleHeight = universalSettings.screenHeightScale(latteView.positioner.currentScreenName);
        }

        PlasmaCore.FrameSvgItem{
            id: backgroundFrameSvgItem
            anchors.fill: parent
            imagePath: "dialogs/background"
            enabledBorders: viewConfig.enabledBorders

            onEnabledBordersChanged: viewConfig.updateEffects()
            Component.onCompleted: viewConfig.updateEffects()

            LatteExtraControls.DragCorner {
                id: dragCorner
            }
        }

        PlasmaComponents.Label{
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            text: dialog.advancedLevel ?
                      i18nc("view settings width scale","Width %0%").arg(userScaleWidth * 100) :
                      i18nc("view settings width scale","Width %0% / Height %1%").arg(userScaleWidth * 100).arg(userScaleHeight * 100)
            visible: dragCorner.isActive
        }

        ColumnLayout {
            id: content

            Layout.minimumWidth: width
            Layout.minimumHeight: calculatedHeight
            Layout.preferredWidth: width
            Layout.preferredHeight: calculatedHeight
            width: (dialog.appliedWidth - units.smallSpacing * 2)

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            spacing: units.smallSpacing

            property int calculatedHeight: header.height + headerSpacer.height+ tabBar.height + pagesBackground.height + actionButtons.height + spacing * 3

            Keys.onPressed: {
                if (event.key === Qt.Key_Escape) {
                    viewConfig.hideConfigWindow();
                }
            }

            Component.onCompleted: forceActiveFocus();

            RowLayout {
                id: header
                Layout.fillWidth: true

                spacing: 0

                Item {
                    id: trademark
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    Layout.fillWidth: false
                    Layout.topMargin: units.smallSpacing
                    Layout.preferredWidth: width
                    Layout.preferredHeight: height

                    width: latteTrademark.width + units.smallSpacing
                    height: trademarkHeight

                    readonly property int trademarkHeight: 48

                    PlasmaCore.SvgItem{
                        id: latteTrademark
                        width: Qt.application.layoutDirection !== Qt.RightToLeft ? Math.ceil(1.70 * height) : height
                        height: trademark.height

                        svg: PlasmaCore.Svg{
                            imagePath: Qt.application.layoutDirection !== Qt.RightToLeft ? universalSettings.trademarkPath() : universalSettings.trademarkIconPath()
                        }
                    }
                }

                Item{
                    id: headerSpacer
                    Layout.minimumHeight: advancedSettings.height + 2*units.smallSpacing
                }

                ColumnLayout {
                    PlasmaComponents3.ToolButton {
                        id: pinButton

                        Layout.fillWidth: false
                        Layout.fillHeight: false
                        Layout.preferredWidth: width
                        Layout.preferredHeight: height
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        Layout.bottomMargin: units.smallSpacing * 1.5
                        //!avoid editMode box shadow
                        Layout.topMargin: units.smallSpacing * 3
                        Layout.rightMargin: units.smallSpacing * 2

                        icon.name: "window-pin"
                        checkable: true

                        width: 7 * units.smallSpacing
                        height: width

                        property bool inStartup: true

                        onClicked: {
                            plasmoid.configuration.configurationSticker = checked
                            viewConfig.setSticker(checked)
                        }

                        Component.onCompleted: {
                            checked = plasmoid.configuration.configurationSticker
                            viewConfig.setSticker(plasmoid.configuration.configurationSticker)
                        }
                    }

                    RowLayout {
                        id: advancedSettings
                        Layout.fillWidth: true
                        Layout.rightMargin: units.smallSpacing * 2
                        Layout.alignment: Qt.AlignRight | Qt.AlignTop

                        PlasmaComponents.Label {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignRight
                        }

                        PlasmaComponents.Label {
                            id: advancedLbl
                            Layout.alignment: Qt.AlignRight
                            //  opacity: dialog.basicLevel ? basicOpacity : 1

                            //! TODO: the term here is not accurate because the expert settings mode
                            //! is used currently. In the future this term will be rethought if
                            //! it must remain or be changed
                            text: i18nc("advanced settings", "Advanced")

                            readonly property real textColorBrightness: colorBrightness(theme.textColor)
                            readonly property real basicOpacity: textColorBrightness > 127 ? 0.7 : 0.3

                            color: {
                                if (dialog.basicLevel) {
                                    return textColorBrightness > 127 ? Qt.darker(theme.textColor, 1.4) : Qt.lighter(theme.textColor, 2.8);
                                }

                                return theme.textColor;
                            }

                            function colorBrightness(color) {
                                return colorBrightnessFromRGB(color.r * 255, color.g * 255, color.b * 255);
                            }

                            // formula for brightness according to:
                            // https://www.w3.org/TR/AERT/#color-contrast
                            function colorBrightnessFromRGB(r, g, b) {
                                return (r * 299 + g * 587 + b * 114) / 1000
                            }

                            MouseArea {
                                id: advancedMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    advancedSwitch.checked = !advancedSwitch.checked;
                                }
                            }
                        }

                        LatteComponents.Switch {
                            id: advancedSwitch
                            checked: universalSettings.inAdvancedModeForEditSettings && viewConfig.isReady

                            onCheckedChanged: {
                                if (viewConfig.isReady) {
                                    universalSettings.inAdvancedModeForEditSettings = checked;
                                }
                            }
                        }
                    }
                }
            }

            PlasmaComponents.TabBar {
                id: tabBar
                Layout.fillWidth: true
                Layout.maximumWidth: (dialog.appliedWidth - units.smallSpacing * 2)

                readonly property int visibleStaticPages: dialog.advancedLevel ? 3 : 2

                PlasmaComponents.TabButton {
                    id: behaviorTabBtn
                    text: i18n("Behavior")
                    onCheckedChanged: {
                        if (checked && pagesStackView.currentItem !== behaviorPage) {
                            pagesStackView.forwardSliding = true;
                            pagesStackView.replace(pagesStackView.currentItem, behaviorPage);
                        }
                    }

                    Connections {
                        target: viewConfig
                        onIsReadyChanged: {
                            if (viewConfig.isReady) {
                                tabBar.currentTab = behaviorTabBtn;
                            }
                        }
                    }
                }

                PlasmaComponents.TabButton {
                    id: appearanceTabBtn
                    text: i18n("Appearance")
                    onCheckedChanged: {
                        if (checked && pagesStackView.currentItem !== appearancePage) {
                            pagesStackView.forwardSliding = (pagesStackView.currentItem.pageIndex > 1);
                            pagesStackView.replace(pagesStackView.currentItem, appearancePage);
                        }
                    }
                }
                PlasmaComponents.TabButton {
                    id: effectsTabBtn
                    text: i18n("Effects")
                    visible: dialog.advancedLevel

                    onCheckedChanged: {
                        if (checked && pagesStackView.currentItem !== effectsPage) {
                            pagesStackView.forwardSliding = (pagesStackView.currentItem.pageIndex > 2);
                            pagesStackView.replace(pagesStackView.currentItem, effectsPage);
                        }
                    }
                }

                Repeater {
                    id: tasksTabButtonRepeater
                    model: latteView.extendedInterface.latteTasksModel

                    PlasmaComponents.TabButton {
                        text: index >= 1 ? i18nc("tasks header and index","Tasks <%0>").arg(index+1) : i18n("Tasks")
                        onCheckedChanged: {
                            if (checked && pagesStackView.currentItem !== tasksRepeater.itemAt(index)) {
                                pagesStackView.forwardSliding = (pagesStackView.currentItem.pageIndex > (tabBar.visibleStaticPages + index));
                                pagesStackView.replace(pagesStackView.currentItem, tasksRepeater.itemAt(index));
                            }
                        }
                    }
                }
            }

            Item {
                id: pagesBackground
                Layout.fillWidth: true
                Layout.fillHeight: false
                Layout.minimumWidth: dialog.appliedWidth - units.smallSpacing * 4
                Layout.minimumHeight: height
                Layout.maximumHeight: height

                width: dialog.appliedWidth - units.smallSpacing * 3
                height: availableFreeHeight + units.smallSpacing * 4

                //fix the height binding loop when showing the configuration window
                property int availableFreeHeight: dialog.appliedHeight - header.height - headerSpacer.height - tabBar.height - actionButtons.height - 2 * units.smallSpacing

                // Header
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: -units.smallSpacing + 2
                    anchors.leftMargin: -2*units.smallSpacing
                    anchors.rightMargin: -2*units.smallSpacing

                    height: parent.height // dialog.height - (header.height + tabBar.height + units.smallSpacing * 1.5) + 2
                    color: theme.backgroundColor
                    border.width: 1
                    border.color: dialog.borderColor
                }

                PlasmaExtras.ScrollArea {
                    id: scrollArea

                    anchors.fill: parent
                    verticalScrollBarPolicy: Qt.ScrollBarAsNeeded
                    horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff

                    flickableItem.flickableDirection: Flickable.VerticalFlick

                    QtQuickControls212.StackView {
                        id: pagesStackView
                        width: currentItem.width
                        height: currentItem.height

                        property bool forwardSliding: true

                        replaceEnter: Transition {
                            ParallelAnimation {
                                PropertyAnimation {
                                    property: "x"
                                    from: pagesStackView.forwardSliding ? -pagesBackground.width : pagesBackground.width
                                    to: 0
                                    duration: 350
                                }

                                PropertyAnimation {
                                    property: "opacity"
                                    from: 0
                                    to: 1
                                    duration: 350
                                }
                            }
                        }

                        replaceExit: Transition {
                            ParallelAnimation {
                                PropertyAnimation {
                                    property: "x"
                                    from: 0
                                    to: pagesStackView.forwardSliding ? pagesBackground.width : -pagesBackground.width
                                    duration: 350
                                }

                                PropertyAnimation {
                                    property: "opacity"
                                    from: 1
                                    to: 0
                                    duration: 350
                                }
                            }
                        }

                        onDepthChanged:  {
                            if (depth === 0) {
                                pagesStackView.forwardSliding = true;
                                push(behaviorPage);
                            }
                        }
                    }
                }

                Item {
                    id:hiddenPages
                    anchors.fill: parent
                    visible: false

                    Pages.BehaviorConfig {
                        id: behaviorPage
                        readonly property int pageIndex:0

                        Component.onCompleted: {
                            pagesStackView.push(behaviorPage);
                        }
                    }

                    Pages.AppearanceConfig {
                        id: appearancePage
                        readonly property int pageIndex:1
                    }

                    Pages.EffectsConfig {
                        id: effectsPage
                        readonly property int pageIndex:2
                    }

                    Repeater {
                        id: tasksRepeater
                        model: plasmoid && plasmoid.configuration && latteView ? latteView.extendedInterface.latteTasksModel : 0

                        Pages.TasksConfig {
                            readonly property int pageIndex: tabBar.visibleStaticPages+index
                        }
                    }
                }
            }

            RowLayout {
                id: actionButtons
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                spacing: units.largeSpacing

                LatteComponents.ComboBoxButton {
                    id: actionsComboBtn
                    Layout.fillWidth: true
                    implicitWidth: removeView.implicitWidth
                    implicitHeight: removeView.implicitHeight

                    buttonEnabled: true
                    buttonText: i18n("New Dock")
                    buttonIconSource: "list-add"
                    buttonToolTip: i18n("Add a new dock")

                    comboBoxEnabled: true
                    comboBoxBlankSpaceForEmptyIcons: true
                    comboBoxPopUpAlignRight: Qt.application.layoutDirection === Qt.RightToLeft
                    comboBoxEnabledRole: "enabled"
                    comboBoxTextRole: "name"
                    comboBoxIconRole: "icon"
                    comboBoxMinimumPopUpWidth: actionsModel.count > 1 ? dialog.width / 2 : 150

                    property var centralLayoutsNames: []

                    Component.onCompleted: {
                        comboBox.model = actionsModel;
                    }

                    ListModel {
                        id: actionsModel
                    }

                    Connections{
                        target: actionsComboBtn.comboBox

                        Component.onCompleted:actionsComboBtn.updateModel();

                        onActivated: {
                            var item = actionsModel.get(index);

                            if (item && item.actionId === "new:") {
                                latteView.layout.newView(item.templateId);
                            } else  if (item && item.actionId === "export:") {
                                latteView.exportTemplate();
                            } else  if (item && item.actionId === "copy:") {
                                latteView.copyView();
                            } else if (item && item.actionId === "move:") {
                                var layouts = actionsComboBtn.centralLayoutsNames;
                                latteView.positioner.hideDockDuringMovingToLayout(layouts[index-1]);
                            }

                            actionsComboBtn.comboBox.currentIndex = -1;
                        }

                        onEnabledChanged: {
                            if (enabled) {
                                actionsComboBtn.updateModel();
                            } else {
                                actionsComboBtn.emptyModel();
                            }
                        }
                    }

                    Connections{
                        target: actionsComboBtn.button
                        onClicked: latteView.layout.newView(layoutsManager.viewTemplateIds()[0])
                    }

                    Connections{
                        target: latteView
                        onTypeChanged: actionsComboBtn.updateCopyText();
                        onLayoutChanged: actionsComboBtn.updateModel();
                    }

                    Connections{
                        target: viewConfig
                        onIsReadyChanged: {
                            if (viewConfig.isReady) {
                                actionsComboBtn.updateModel();
                            }
                        }
                    }

                    Connections {
                        target: layoutsManager
                        onViewTemplatesChanged: actionsComboBtn.updateModel();
                    }

                    function updateModel() {
                        actionsModel.clear();

                        var tempCentralLayouts = layoutsManager.centralLayoutsNames();

                        if (tempCentralLayouts.length > 0) {
                            var curIndex = tempCentralLayouts.indexOf(latteView.layout.name);
                            if (curIndex >=0) {
                                tempCentralLayouts.splice(curIndex,1);
                            }

                            centralLayoutsNames = tempCentralLayouts;
                            var iconArrow = Qt.application.layoutDirection === Qt.RightToLeft ? 'arrow-left' : 'arrow-right';

                            for(var i=0; i<centralLayoutsNames.length; ++i) {
                                var layout = {
                                    actionId: 'move:',
                                    enabled: true,
                                    name: i18n("Move to %0").arg(centralLayoutsNames[i]),
                                    icon: iconArrow
                                };
                                actionsModel.append(layout);
                            }
                        }

                        var exporttemplate = {actionId: 'export:', enabled: true, name: i18n("Export as Template"), icon: 'document-export'};
                        actionsModel.append(exporttemplate);

                        var copy = {actionId: 'copy:', enabled: true, name: '', icon: 'edit-copy'};
                        actionsModel.append(copy);
                        updateCopyText();

                        var viewTemplateIds = layoutsManager.viewTemplateIds();

                        if (viewTemplateIds.length > 1) {
                            var viewTemplateNames = layoutsManager.viewTemplateNames();

                            for(var i=viewTemplateIds.length-1; i>=1; --i) {
                                //! add view templates on reverse
                                var viewtemplate = {
                                    actionId: 'new:',
                                    enabled: true,
                                    templateId: viewTemplateIds[i],
                                    name: i18n("New %0").arg(viewTemplateNames[i]),
                                    icon: 'list-add'
                                };
                                actionsModel.append(viewtemplate);
                            }

                        }

                        actionsComboBtn.comboBox.currentIndex = -1;
                    }

                    function emptyModel() {
                        actionsModel.clear();
                        actionsComboBtn.comboBox.currentIndex = -1;
                    }

                    function updateCopyText() {
                        for (var i=0; i<actionsModel.count; ++i) {
                            var item = actionsModel.get(i);
                            if (item.actionId === "copy:") {
                                var copyText = latteView.type === LatteCore.Types.DockView ? i18n("Copy Dock") : i18n("Copy Panel")
                                item.name = copyText;
                                break;
                            }
                        }
                    }
                }

                PlasmaComponents.Button {
                    id: removeView
                    Layout.fillWidth: true
                    enabled: dialog.advancedLevel
                    text: i18n("Remove")
                    iconSource: "delete"
                    opacity: enabled ? 1 : 0
                    tooltip: i18n("Remove current dock")

                    onClicked: latteView.removeView()
                }

                PlasmaComponents.Button {
                    id: closeButton
                    Layout.fillWidth: true

                    text: i18n("Close")
                    iconSource: "dialog-close"
                    tooltip: i18n("Close settings window")

                    onClicked: viewConfig.hideConfigWindow();
                }
            }
        }

        /*PlasmaExtras.PlasmoidHeading {
            id: plasmoidFooter
            location: PlasmaExtras.PlasmoidHeading.Location.Footer
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            height: actionButtons.height + units.smallSpacing * 2.5
            // So that it doesn't appear over the content view, which results in
            // the footer controls being inaccessible
            z: -9999
        }*/
    }
}
