import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

PopupWindow {
  id: settings

  required property var dock

  property var anchorCell: null
  property bool open: false
  property bool locked: false
  property real lockRX: 0
  property real lockRY: 0
  property real lockScreenX: 0
  property real lockScreenY: 0
  property int lockRadius: Style.cornerRadius

  function openFor(cell) {
    settings.anchorCell = cell
    settings.lockAtAnchor()
    if (settings.open) {
      settings.anchor.updateAnchor()
      return
    }
    settings.open = true
    settings.dock.holdForPopup()
  }

  function anchorWindowScreenName() {
    var target = settings.anchorCell
    var window = target ? target.QsWindow.window : null
    if (window && window.screen) return String(window.screen.name || "")
    return ""
  }

  function lockAtAnchor() {
    var target = settings.anchorCell
    var window = target ? target.QsWindow.window : null
    if (!window) return
    var p = settings.dock.popupAnchorPoint(target, window, settings.implicitWidth, settings.implicitHeight, true)
    settings.lockRX = p.x
    settings.lockRY = p.y
    var wsr = settings.dock.windowScreenRect(settings.anchorWindowScreenName())
    if (wsr) {
      settings.lockScreenX = wsr.x + p.x
      settings.lockScreenY = wsr.y + p.y
    } else {
      settings.lockScreenX = p.x
      settings.lockScreenY = p.y
    }
    settings.lockRadius = Math.min(settings.dock.cardRadius, Style.cornerRadius)
    settings.locked = true
  }

  function close() {
    if (!settings.open) return
    settings.open = false
    settings.dock.popupReleased()
  }

  visible: open
  color: "transparent"

  readonly property int pad: Style.spacing.lg
  readonly property int contentWidth: Style.space(340)
  readonly property var settingsBorder: Border.surfaceSpec("popups", "border", Color.popups.border, Math.max(1, Style.space(1)))

  readonly property int bodyHeight: Math.min(column.implicitHeight, maxBodyHeight)
  readonly property int maxBodyHeight: {
    var m = settings.dock.monitorRect(settings.anchorWindowScreenName())
    if (m) return Math.max(Style.space(320), Math.min(Style.space(680), Math.round(m.height) - Style.space(80)))
    return Style.space(680)
  }

  implicitWidth: contentWidth + pad * 2 + Border.left(settingsBorder) + Border.right(settingsBorder)
  width: contentWidth + pad * 2 + Border.left(settingsBorder) + Border.right(settingsBorder)
  implicitHeight: Math.round(settings.bodyHeight + pad * 2 + Border.top(settingsBorder) + Border.bottom(settingsBorder))

  HyprlandFocusGrab {
    active: settings.open
    windows: {
      var out = [settings]
      var w = settings.anchorCell ? settings.anchorCell.QsWindow.window : null
      if (w) out.push(w)
      return out
    }
    onCleared: settings.close()
  }

  anchor {
    adjustment: PopupAdjustment.Slide
    edges: Edges.Top | Edges.Left
    gravity: settings.dock.popupGravity
    window: settings.anchorCell ? settings.anchorCell.QsWindow.window : null

    onAnchoring: {
      if (!settings.locked) return
      var wsr = settings.dock.windowScreenRect(settings.anchorWindowScreenName())
      if (!wsr) return
      var nx = settings.lockScreenX - wsr.x
      var ny = settings.lockScreenY - wsr.y
      if (nx === anchor.rect.x && ny === anchor.rect.y) return
      anchor.rect.x = nx
      anchor.rect.y = ny
      anchor.rect.width = 1
      anchor.rect.height = 1
    }
  }

  BorderSurface {
    id: card
    anchors.fill: parent
    radius: settings.lockRadius + 4
    color: Util.alpha(Color.popups.background, 0.92)
    borderSpec: settings.settingsBorder

    ScrollView {
      id: scroll
      x: Border.left(settings.settingsBorder) + settings.pad
      y: Border.top(settings.settingsBorder) + settings.pad
      width: settings.contentWidth
      height: settings.bodyHeight
      clip: true
      contentWidth: availableWidth
      ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
      ScrollBar.vertical.policy: column.implicitHeight > scroll.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff

      Column {
        id: column
        width: scroll.availableWidth
        spacing: Style.spacing.xl

        // Header Row
        Item {
          width: settings.contentWidth
          height: 36

          Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.spacing.sm

            Rectangle {
              width: 24
              height: 24
              radius: 6
              color: Util.alpha(Color.accent, 0.2)
              anchors.verticalCenter: parent.verticalCenter

              Text {
                anchors.centerIn: parent
                text: "✨"
                font.pixelSize: 12
              }
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "Liquid Glass Dock"
              color: Color.popups.text
              font.family: Style.font.resolvedFamily
              font.pixelSize: Style.font.bodyLarge || 16
              font.bold: true
            }
          }

          Button {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            iconText: "✕"
            fontSize: Style.font.body
            horizontalPadding: Style.spacing.controlPaddingX
            verticalPadding: Style.spacing.controlPaddingY
            foreground: Color.popups.text
            accent: Color.accent
            onClicked: settings.close()
          }
        }

        // Section builder helper component concept inline
        // APPEARANCE
        Column {
          width: settings.contentWidth
          spacing: Style.spacing.md

          Row {
            spacing: 6
            Text {
              text: "APPEARANCE"
              color: Color.accent
              font.family: Style.font.resolvedFamily
              font.pixelSize: Style.font.caption || 11
              font.bold: true
              letterSpacing: 1.2
            }
          }

          // Card Container for Appearance
          Rectangle {
            width: settings.contentWidth
            height: appearanceCol.implicitHeight + 24
            radius: 12
            color: Util.alpha(Color.popups.text, 0.04)
            border.width: 1
            border.color: Util.alpha(Color.popups.text, 0.08)

            Column {
              id: appearanceCol
              x: 12; y: 12
              width: settings.contentWidth - 24
              spacing: Style.spacing.md

              Column {
                width: parent.width
                spacing: Style.spacing.xs

                Row {
                  width: parent.width
                  Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Icon Size"
                    color: Color.popups.text
                    font.family: Style.font.resolvedFamily
                    font.pixelSize: Style.font.bodySmall
                    font.bold: true
                  }
                  Item { width: 1; height: 1; Layout.fillWidth: true }
                  Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: String(Math.round(sizeSlider.liveValue)) + " px"
                    color: Util.alpha(Color.popups.text, 0.6)
                    font.family: Style.font.resolvedFamily
                    font.pixelSize: Style.font.caption
                  }
                }

                DragSlider {
                  id: sizeSlider
                  width: parent.width
                  minimum: 24
                  maximum: 96
                  step: 2
                  integer: true
                  value: settings.dock.num("iconSize", 44)
                  fillColor: Color.accent
                  knobColor: Color.accent
                  onReleased: function(v) {
                    settings.dock.applySetting("iconSize", String(Math.round(v)))
                  }
                }
              }

              Column {
                width: parent.width
                spacing: Style.spacing.xs

                Row {
                  width: parent.width
                  Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Icon Magnification"
                    color: Color.popups.text
                    font.family: Style.font.resolvedFamily
                    font.pixelSize: Style.font.bodySmall
                    font.bold: true
                  }
                  Item { width: 1; height: 1; Layout.fillWidth: true }
                  Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: String(Math.round(zoomSlider.liveValue)) + "%"
                    color: Util.alpha(Color.popups.text, 0.6)
                    font.family: Style.font.resolvedFamily
                    font.pixelSize: Style.font.caption
                  }
                }

                DragSlider {
                  id: zoomSlider
                  width: parent.width
                  minimum: 0
                  maximum: 100
                  step: 5
                  integer: true
                  value: Math.round(settings.dock.fraction("zoom", 0.48) * 100)
                  fillColor: Color.accent
                  knobColor: Color.accent
                  onReleased: function(v) {
                    settings.dock.applySetting("zoom", String(v / 100))
                  }
                }
              }

              DockToggle {
                width: parent.width
                label: "Gaussian Zoom"
                description: "Bell-curve falloff instead of fishbowl."
                stored: settings.dock.flag("gaussianZoom", true)
                foreground: Color.popups.text
                accent: Color.accent
                onRequestWrite: function(v) { settings.dock.applySetting("gaussianZoom", String(v)) }
              }

              Column {
                width: parent.width
                spacing: Style.spacing.xs

                Row {
                  width: parent.width
                  Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Background Opacity"
                    color: Color.popups.text
                    font.family: Style.font.resolvedFamily
                    font.pixelSize: Style.font.bodySmall
                    font.bold: true
                  }
                  Item { width: 1; height: 1; Layout.fillWidth: true }
                  Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Math.round(bgOpacitySlider.liveValue) + "%"
                    color: Util.alpha(Color.popups.text, 0.6)
                    font.family: Style.font.resolvedFamily
                    font.pixelSize: Style.font.caption
                  }
                }

                DragSlider {
                  id: bgOpacitySlider
                  width: parent.width
                  minimum: 0
                  maximum: 100
                  step: 5
                  integer: true
                  value: Math.round(settings.dock.fraction("backgroundOpacity", 1.0) * 100)
                  fillColor: Color.accent
                  knobColor: Color.accent
                  onReleased: function(v) {
                    Util.execDetached(settings.dock.configCmd + " opacity " + Util.shellQuote(String(v / 100)))
                  }
                }
              }

              Column {
                width: parent.width
                spacing: Style.spacing.xs

                Text {
                  width: parent.width
                  text: "Corner Shape"
                  color: Color.popups.text
                  font.family: Style.font.resolvedFamily
                  font.pixelSize: Style.font.bodySmall
                  font.bold: true
                }

                ButtonGroup {
                  options: [
                    { value: "rounded", label: "Rounded" },
                    { value: "square", label: "Square" },
                    { value: "pill", label: "Pill" }
                  ]
                  value: settings.dock.cornerShape
                  foreground: Color.popups.text
                  background: Color.popups.background
                  accent: Color.accent
                  onChanged: function(v) {
                    Util.execDetached(settings.dock.configCmd + " corner-shape " + Util.shellQuote(String(v)))
                  }
                }
              }

              Column {
                width: parent.width
                spacing: Style.spacing.xs

                Text {
                  width: parent.width
                  text: "Position"
                  color: Color.popups.text
                  font.family: Style.font.resolvedFamily
                  font.pixelSize: Style.font.bodySmall
                  font.bold: true
                }

                ButtonGroup {
                  options: [
                    { value: "bottom", label: "Bottom" },
                    { value: "top", label: "Top" },
                    { value: "left", label: "Left" },
                    { value: "right", label: "Right" }
                  ]
                  value: settings.dock.edge
                  foreground: Color.popups.text
                  background: Color.popups.background
                  accent: Color.accent
                  onChanged: function(v) {
                    settings.dock.applySetting("edge", JSON.stringify(String(v)))
                  }
                }
              }

              DockToggle {
                width: parent.width
                label: "Full Length"
                description: "Span the whole edge of the screen."
                stored: settings.dock.flag("fullWidth", false)
                foreground: Color.popups.text
                accent: Color.accent
                onRequestWrite: function(v) { settings.dock.applySetting("fullWidth", String(v)) }
              }

              DockToggle {
                width: parent.width
                label: "Border Outline"
                description: "Subtle stroke around the dock card."
                stored: settings.dock.flag("border", true)
                foreground: Color.popups.text
                accent: Color.accent
                onRequestWrite: function(v) { settings.dock.applySetting("border", String(v)) }
              }

              Column {
                width: parent.width
                spacing: Style.spacing.xs
                visible: settings.dock.flag("border", true)

                Row {
                  width: parent.width
                  Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Border Opacity"
                    color: Color.popups.text
                    font.family: Style.font.resolvedFamily
                    font.pixelSize: Style.font.bodySmall
                    font.bold: true
                  }
                  Item { width: 1; height: 1; Layout.fillWidth: true }
                  Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Math.round(borderOpacitySlider.liveValue) + "%"
                    color: Util.alpha(Color.popups.text, 0.6)
                    font.family: Style.font.resolvedFamily
                    font.pixelSize: Style.font.caption
                  }
                }

                DragSlider {
                  id: borderOpacitySlider
                  width: parent.width
                  minimum: 0
                  maximum: 100
                  step: 5
                  integer: true
                  value: Math.round(settings.dock.fraction("borderOpacity", 1.0) * 100)
                  fillColor: Color.accent
                  knobColor: Color.accent
                  onReleased: function(v) {
                    settings.dock.applySetting("borderOpacity", String(v / 100))
                  }
                }
              }
            }
          }
        }

        // GLOW
        Column {
          width: settings.contentWidth
          spacing: Style.spacing.md

          Row {
            spacing: 6
            Text {
              text: "GLOW & LIGHTING"
              color: Color.accent
              font.family: Style.font.resolvedFamily
              font.pixelSize: Style.font.caption || 11
              font.bold: true
              letterSpacing: 1.2
            }
          }

          Rectangle {
            width: settings.contentWidth
            height: glowCol.implicitHeight + 24
            radius: 12
            color: Util.alpha(Color.popups.text, 0.04)
            border.width: 1
            border.color: Util.alpha(Color.popups.text, 0.08)

            Column {
              id: glowCol
              x: 12; y: 12
              width: settings.contentWidth - 24
              spacing: Style.spacing.md

              DockToggle {
                width: parent.width
                label: "Border Glow"
                description: "Soft halo blooming out from the dock."
                stored: settings.dock.flag("glow", false)
                foreground: Color.popups.text
                accent: Color.accent
                onRequestWrite: function(v) {
                  Util.execDetached(settings.dock.configCmd + " glow " + (v ? "true" : "false"))
                }
              }

              Column {
                width: parent.width
                spacing: Style.spacing.md
                visible: settings.dock.flag("glow", false)

                Column {
                  width: parent.width
                  spacing: Style.spacing.xs

                  Row {
                    width: parent.width
                    Text {
                      anchors.verticalCenter: parent.verticalCenter
                      text: "Glow Strength"
                      color: Color.popups.text
                      font.family: Style.font.resolvedFamily
                      font.pixelSize: Style.font.bodySmall
                      font.bold: true
                    }
                    Item { width: 1; height: 1; Layout.fillWidth: true }
                    Text {
                      anchors.verticalCenter: parent.verticalCenter
                      text: Math.round(glowStrengthSlider.liveValue) + "%"
                      color: Util.alpha(Color.popups.text, 0.6)
                      font.family: Style.font.resolvedFamily
                      font.pixelSize: Style.font.caption
                    }
                  }

                  DragSlider {
                    id: glowStrengthSlider
                    width: parent.width
                    minimum: 0
                    maximum: 100
                    step: 5
                    integer: true
                    value: Math.round(settings.dock.fraction("glowAmount", 0.5) * 100)
                    fillColor: Color.accent
                    knobColor: Color.accent
                    onReleased: function(v) {
                      Util.execDetached(settings.dock.configCmd + " glow-amount " + Util.shellQuote(String(v / 100)))
                    }
                  }
                }

                Column {
                  width: parent.width
                  spacing: Style.spacing.xs

                  Text {
                    width: parent.width
                    text: "Glow Focus"
                    color: Color.popups.text
                    font.family: Style.font.resolvedFamily
                    font.pixelSize: Style.font.bodySmall
                    font.bold: true
                  }

                  ButtonGroup {
                    options: [
                      { value: "full", label: "Full" },
                      { value: "top", label: "Top" },
                      { value: "bottom", label: "Bottom" }
                    ]
                    value: {
                      var focus = String(settings.dock.config.glowFocus || "")
                      return (focus === "bottom" || focus === "top") ? focus : "full"
                    }
                    foreground: Color.popups.text
                    background: Color.popups.background
                    accent: Color.accent
                    onChanged: function(v) {
                      Util.execDetached(settings.dock.configCmd + " glow-focus " + Util.shellQuote(String(v)))
                    }
                  }
                }
              }
            }
          }
        }

        // BEHAVIOUR
        Column {
          width: settings.contentWidth
          spacing: Style.spacing.md

          Row {
            spacing: 6
            Text {
              text: "BEHAVIOUR"
              color: Color.accent
              font.family: Style.font.resolvedFamily
              font.pixelSize: Style.font.caption || 11
              font.bold: true
              letterSpacing: 1.2
            }
          }

          Rectangle {
            width: settings.contentWidth
            height: behaviorCol.implicitHeight + 24
            radius: 12
            color: Util.alpha(Color.popups.text, 0.04)
            border.width: 1
            border.color: Util.alpha(Color.popups.text, 0.08)

            Column {
              id: behaviorCol
              x: 12; y: 12
              width: settings.contentWidth - 24
              spacing: Style.spacing.md

              DockToggle {
                width: parent.width
                label: "Auto-hide"
                description: "Slide off-screen until edge is brushed."
                stored: settings.dock.flag("autohide", true)
                foreground: Color.popups.text
                accent: Color.accent
                onRequestWrite: function(v) { settings.dock.applySetting("autohide", String(v)) }
              }

              DockToggle {
                width: parent.width
                label: "Hover Tooltips"
                description: "Show icon names on hover."
                stored: settings.dock.flag("tooltips", true)
                foreground: Color.popups.text
                accent: Color.accent
                onRequestWrite: function(v) { settings.dock.applySetting("tooltips", String(v)) }
              }
            }
          }
        }

        // TASKBAR SYNC
        Column {
          width: settings.contentWidth
          spacing: Style.spacing.md

          Row {
            spacing: 6
            Text {
              text: "TASKBAR SYNC"
              color: Color.accent
              font.family: Style.font.resolvedFamily
              font.pixelSize: Style.font.caption || 11
              font.bold: true
              letterSpacing: 1.2
            }
          }

          Rectangle {
            width: settings.contentWidth
            height: taskbarCol.implicitHeight + 24
            radius: 12
            color: Util.alpha(Color.popups.text, 0.04)
            border.width: 1
            border.color: Util.alpha(Color.popups.text, 0.08)

            Column {
              id: taskbarCol
              x: 12; y: 12
              width: settings.contentWidth - 24
              spacing: Style.spacing.md

              DockToggle {
                width: parent.width
                label: "Sync Opacity"
                description: "Mirror dock opacity onto the taskbar."
                stored: settings.dock.flag("matchBarOpacity", false)
                foreground: Color.popups.text
                accent: Color.accent
                onRequestWrite: function(v) {
                  Util.execDetached(settings.dock.configCmd + " matchbar-opacity " + (v ? "true" : "false"))
                }
              }

              DockToggle {
                width: parent.width
                label: "Sync Corners"
                description: "Mirror dock corner shape onto taskbar."
                stored: settings.dock.flag("matchBarCorners", false)
                foreground: Color.popups.text
                accent: Color.accent
                onRequestWrite: function(v) {
                  Util.execDetached(settings.dock.configCmd + " matchbar-corners " + (v ? "true" : "false"))
                }
              }

              DockToggle {
                width: parent.width
                label: "Sync Glow"
                description: "Mirror dock border glow onto taskbar."
                stored: settings.dock.flag("matchBarGlow", false)
                foreground: Color.popups.text
                accent: Color.accent
                onRequestWrite: function(v) {
                  Util.execDetached(settings.dock.configCmd + " matchbar-glow " + (v ? "true" : "false"))
                }
              }
            }
          }
        }

        // DEVELOPER INFO / FOOTER
        Rectangle {
          width: settings.contentWidth
          height: 48
          radius: 12
          color: Util.alpha(Color.accent, 0.08)
          border.width: 1
          border.color: Util.alpha(Color.accent, 0.2)

          Row {
            anchors.centerIn: parent
            spacing: 8

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "⚡"
              font.pixelSize: 13
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "Developed by Omid.Dev"
              color: Color.popups.text
              font.family: Style.font.resolvedFamily
              font.pixelSize: Style.font.bodySmall
              font.bold: true
            }
          }
        }

      }
    }
  }
}
