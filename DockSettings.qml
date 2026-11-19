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
  readonly property int contentWidth: Style.space(350)
  readonly property var settingsBorder: Border.surfaceSpec("popups", "border", Color.popups.border, Math.max(1, Style.space(1)))

  readonly property int bodyHeight: Math.min(column.implicitHeight, maxBodyHeight)
  readonly property int maxBodyHeight: {
    var m = settings.dock.monitorRect(settings.anchorWindowScreenName())
    if (m) return Math.max(Style.space(320), Math.min(Style.space(700), Math.round(m.height) - Style.space(80)))
    return Style.space(700)
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
    radius: settings.lockRadius + 6
    color: Util.alpha(Color.popups.background, 0.94)
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
          height: 40

          Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Rectangle {
              width: 32
              height: 32
              radius: 8
              color: Util.alpha(Color.accent, 0.2)
              anchors.verticalCenter: parent.verticalCenter

              Text {
                anchors.centerIn: parent
                text: "✨"
                font.pixelSize: 15
              }
            }

            Column {
              anchors.verticalCenter: parent.verticalCenter
              spacing: 2
              Text {
                text: "Liquid Glass Dock"
                color: Color.popups.text
                font.family: Style.font.resolvedFamily
                font.pixelSize: 15
                font.bold: true
              }
              Text {
                text: "macOS Style Desktop Experience"
                color: Util.alpha(Color.popups.text, 0.5)
                font.family: Style.font.resolvedFamily
                font.pixelSize: 11
              }
            }
          }

          Button {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            iconText: "✕"
            fontSize: Style.font.body
            horizontalPadding: 10
            verticalPadding: 6
            foreground: Color.popups.text
            accent: Color.accent
            onClicked: settings.close()
          }
        }

        // Section Builder Component
        Column {
          width: settings.contentWidth
          spacing: Style.spacing.md

          // Section wrapper helper
          component SectionBox: Column {
             width: parent.width
             spacing: Style.spacing.sm
             property string title: ""
             property string icon: ""

             Row {
               spacing: 8
               anchors.left: parent.left
               anchors.leftMargin: 4
               Text {
                 text: box.icon
                 font.pixelSize: 13
                 anchors.verticalCenter: parent.verticalCenter
               }
               Text {
                 text: box.title
                 color: Color.accent
                 font.family: Style.font.resolvedFamily
                 font.pixelSize: 11
                 font.bold: true
                 letterSpacing: 1.5
                 anchors.verticalCenter: parent.verticalCenter
               }
             }

             Rectangle {
               width: parent.width
               height: innerCol.implicitHeight + 28
               radius: 14
               color: Util.alpha(Color.popups.text, 0.03)
               border.width: 1
               border.color: Util.alpha(Color.popups.text, 0.08)

               Column {
                 id: innerCol
                 x: 14; y: 14
                 width: parent.width - 28
                 spacing: Style.spacing.lg
                 children: box.data
               }
             }
          }

          // 1. APPEARANCE
          SectionBox {
            title: "APPEARANCE"
            icon: "🎨"
            
            Column { width: parent.width; spacing: 16
               // Icon Size Slider
               Column { width: parent.width; spacing: 8
                 Row { width: parent.width
                   Text { text: "📐 Icon Size"; font.bold: true; color: Color.popups.text; font.pixelSize: 13 }
                   Item { Layout.fillWidth: true }
                   Rectangle {
                     radius: 6; color: Util.alpha(Color.accent, 0.15)
                     width: 44; height: 22
                     Text { anchors.centerIn: parent; text: Math.round(sizeSlider.liveValue) + "px"; color: Color.accent; font.pixelSize: 11; font.bold: true }
                   }
                 }
                 DragSlider {
                   id: sizeSlider
                   width: parent.width
                   minimum: 24; maximum: 96; step: 2; integer: true
                   value: settings.dock.num("iconSize", 44)
                   fillColor: Color.accent; knobColor: Color.accent
                   onReleased: function(v) { settings.dock.applySetting("iconSize", String(Math.round(v))) }
                 }
               }

               // Icon Magnification Slider
               Column { width: parent.width; spacing: 8
                 Row { width: parent.width
                   Text { text: "🔍 Magnification Scale"; font.bold: true; color: Color.popups.text; font.pixelSize: 13 }
                   Item { Layout.fillWidth: true }
                   Rectangle {
                     radius: 6; color: Util.alpha(Color.accent, 0.15)
                     width: 44; height: 22
                     Text { anchors.centerIn: parent; text: Math.round(zoomSlider.liveValue) + "%"; color: Color.accent; font.pixelSize: 11; font.bold: true }
                   }
                 }
                 DragSlider {
                   id: zoomSlider
                   width: parent.width
                   minimum: 0; maximum: 100; step: 5; integer: true
                   value: Math.round(settings.dock.fraction("zoom", 0.48) * 100)
                   fillColor: Color.accent; knobColor: Color.accent
                   onReleased: function(v) { settings.dock.applySetting("zoom", String(v / 100)) }
                 }
               }

               // Gaussian Zoom Toggle
               DockToggle {
                 width: parent.width
                 label: "🌊 Gaussian Zoom Falloff"
                 description: "Smooth bell-curve scaling effect."
                 stored: settings.dock.flag("gaussianZoom", true)
                 foreground: Color.popups.text
                 accent: Color.accent
                 onRequestWrite: function(v) { settings.dock.applySetting("gaussianZoom", String(v)) }
               }

               // Corner Shape
               Column { width: parent.width; spacing: 8
                 Text { text: "🔲 Corner Radius Style"; font.bold: true; color: Color.popups.text; font.pixelSize: 13 }
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

               // Position
               Column { width: parent.width; spacing: 8
                 Text { text: "📍 Screen Position"; font.bold: true; color: Color.popups.text; font.pixelSize: 13 }
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

               // Full Length
               DockToggle {
                 width: parent.width
                 label: "📏 Full Screen Edge"
                 description: "Span across the entire edge."
                 stored: settings.dock.flag("fullWidth", false)
                 foreground: Color.popups.text
                 accent: Color.accent
                 onRequestWrite: function(v) { settings.dock.applySetting("fullWidth", String(v)) }
               }
            }
          }

          // 2. GLOW & LIGHTING
          SectionBox {
            title: "GLOW & LIGHTING"
            icon: "✨"
            
            Column { width: parent.width; spacing: 16
               DockToggle {
                 width: parent.width
                 label: "🌟 Border Glow Halo"
                 description: "Soft vibrant illumination around the border."
                 stored: settings.dock.flag("glow", false)
                 foreground: Color.popups.text
                 accent: Color.accent
                 onRequestWrite: function(v) {
                   Util.execDetached(settings.dock.configCmd + " glow " + (v ? "true" : "false"))
                 }
               }

               Column { width: parent.width; spacing: 8; visible: settings.dock.flag("glow", false)
                 Row { width: parent.width
                   Text { text: "⚡ Glow Intensity"; font.bold: true; color: Color.popups.text; font.pixelSize: 13 }
                   Item { Layout.fillWidth: true }
                   Rectangle {
                     radius: 6; color: Util.alpha(Color.accent, 0.15)
                     width: 44; height: 22
                     Text { anchors.centerIn: parent; text: Math.round(glowStrengthSlider.liveValue) + "%"; color: Color.accent; font.pixelSize: 11; font.bold: true }
                   }
                 }
                 DragSlider {
                   id: glowStrengthSlider
                   width: parent.width
                   minimum: 0; maximum: 100; step: 5; integer: true
                   value: Math.round(settings.dock.fraction("glowAmount", 0.5) * 100)
                   fillColor: Color.accent; knobColor: Color.accent
                   onReleased: function(v) {
                     Util.execDetached(settings.dock.configCmd + " glow-amount " + Util.shellQuote(String(v / 100)))
                   }
                 }
               }
            }
          }
          
          // 3. BEHAVIOUR
          SectionBox {
             title: "BEHAVIOUR & INTERACTION"
             icon: "⚙️"
             
             Column { width: parent.width; spacing: 16
               DockToggle {
                 width: parent.width
                 label: "👻 Intelligent Auto-hide"
                 description: "Slide off-screen until edge is approached."
                 stored: settings.dock.flag("autohide", true)
                 foreground: Color.popups.text
                 accent: Color.accent
                 onRequestWrite: function(v) { settings.dock.applySetting("autohide", String(v)) }
               }
               DockToggle {
                 width: parent.width
                 label: "🏷️ Hover Tooltips"
                 description: "Display app names on mouse hover."
                 stored: settings.dock.flag("tooltips", true)
                 foreground: Color.popups.text
                 accent: Color.accent
                 onRequestWrite: function(v) { settings.dock.applySetting("tooltips", String(v)) }
               }
             }
          }

          // 4. TASKBAR SYNC
          SectionBox {
             title: "TASKBAR INTEGRATION"
             icon: "🔗"
             
             Column { width: parent.width; spacing: 16
               DockToggle {
                 width: parent.width
                 label: "🔄 Sync Taskbar Opacity"
                 description: "Match taskbar opacity with the dock."
                 stored: settings.dock.flag("matchBarOpacity", false)
                 foreground: Color.popups.text
                 accent: Color.accent
                 onRequestWrite: function(v) {
                   Util.execDetached(settings.dock.configCmd + " matchbar-opacity " + (v ? "true" : "false"))
                 }
               }
               DockToggle {
                 width: parent.width
                 label: "🔄 Sync Taskbar Corners"
                 description: "Match corner shape with the dock."
                 stored: settings.dock.flag("matchBarCorners", false)
                 foreground: Color.popups.text
                 accent: Color.accent
                 onRequestWrite: function(v) {
                   Util.execDetached(settings.dock.configCmd + " matchbar-corners " + (v ? "true" : "false"))
                 }
               }
               DockToggle {
                 width: parent.width
                 label: "🔄 Sync Taskbar Glow"
                 description: "Match border glow with the dock."
                 stored: settings.dock.flag("matchBarGlow", false)
                 foreground: Color.popups.text
                 accent: Color.accent
                 onRequestWrite: function(v) {
                   Util.execDetached(settings.dock.configCmd + " matchbar-glow " + (v ? "true" : "false"))
                 }
               }
             }
          }

          // Footer Badge
          Rectangle {
            width: settings.contentWidth
            height: 52
            radius: 14
            color: Util.alpha(Color.accent, 0.08)
            border.width: 1
            border.color: Util.alpha(Color.accent, 0.25)
            Row {
              anchors.centerIn: parent
              spacing: 10
              Text { text: "⚡"; font.pixelSize: 15 }
              Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1
                Text { text: "Mac Dock Liquid Glass"; color: Color.popups.text; font.pixelSize: 11; font.bold: true }
                Text { text: "Developed by Omid.Dev"; color: Color.accent; font.pixelSize: 10; font.bold: true }
              }
            }
          }
        }
      }
    }
  }
}
