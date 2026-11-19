import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Ui

// Hover preview for a dock item: a row of single-frame thumbnails for every
// window the app currently has, anchored above its tile. Clicking a thumbnail
// focuses that window. Falls back to the window title when the compositor
// cannot export a frame (minimised / off-screen / unsupported).
PopupWindow {
  id: preview

  required property var dock

  property var item: null
  property var entry: null
  property var anchorCell: null
  property bool open: false

  property var wins: []
  readonly property var liveWins: open && item ? dock.windowsFor(item) : []
  onLiveWinsChanged: adoptWins(liveWins)

  function adoptWins(next) {
    next = next || []
    if (dock.sameWindows(wins, next)) return
    wins = next.slice()
  }

  function openFor(cell) {
    var canonical = dock.displayItems[cell.index]
    preview.item = canonical !== undefined ? canonical : cell.modelData
    preview.entry = cell.entry
    preview.anchorCell = cell
    preview.adoptWins(dock.windowsFor(cell.modelData))
    if (preview.open) {
      preview.anchor.updateAnchor()
      return
    }
    preview.open = true
    preview.dock.previewOpen = true
    preview.dock.holdForPopup()
    preview.closeTimer.stop()
  }

  function close() {
    if (!preview.open) return
    preview.open = false
    preview.dock.previewOpen = false
    preview.dock.releasePopup()
  }

  // Keep the popup alive while the pointer travels between the icon and it.
  Timer {
    id: closeTimer
    interval: 260
    onTriggered: preview.close()
  }

  visible: open
  color: "transparent"

  readonly property int pad: Style.spacing.sm
  readonly property var previewBorder: Border.surfaceSpec("popups", "border", Color.popups.border, Math.max(1, Style.space(2)))

  // Adopt wins on open even if liveWins did not change identity.
  onOpenChanged: {
    if (open) adoptWins(dock.windowsFor(item))
  }

  implicitWidth: Math.round(thumbs.implicitWidth + pad * 2 + Border.left(previewBorder) + Border.right(previewBorder))
  implicitHeight: Math.round(thumbs.implicitHeight + pad * 2 + Border.top(previewBorder) + Border.bottom(previewBorder))

  HyprlandFocusGrab {
    active: preview.open
    windows: {
      var out = [preview]
      var w = preview.anchorCell ? preview.anchorCell.QsWindow.window : null
      if (w) out.push(w)
      return out
    }
    onCleared: preview.close()
  }

  HoverHandler {
    onHoveredChanged: {
      if (hovered) closeTimer.stop()
      else closeTimer.restart()
    }
  }

  anchor {
    adjustment: PopupAdjustment.Slide
    edges: Edges.Top | Edges.Left
    gravity: preview.dock.popupGravity
    window: preview.anchorCell ? preview.anchorCell.QsWindow.window : null

    onAnchoring: {
      var target = preview.anchorCell
      var window = target ? target.QsWindow.window : null
      if (!window) return
      var p = preview.dock.popupAnchorPoint(target, window, preview.implicitWidth, preview.implicitHeight)
      anchor.rect.x = p.x
      anchor.rect.y = p.y
      anchor.rect.width = 1
      anchor.rect.height = 1
    }
  }

  BorderSurface {
    id: card
    anchors.fill: parent
    radius: Math.min(preview.dock.cardRadius, Style.cornerRadius)
    color: Util.alpha(Color.popups.background, 0.97)
    borderSpec: preview.previewBorder

    Row {
      id: thumbs
      x: Border.left(preview.previewBorder) + preview.pad
      y: Border.top(preview.previewBorder) + preview.pad
      spacing: Style.spacing.sm

      Repeater {
        model: preview.wins

        delegate: Item {
          id: thumb
          required property var modelData
          required property int index

          readonly property var win: modelData
          readonly property string title: String(win && win.title ? win.title : (win && win.appId ? win.appId : "window"))

          width: 170
          height: 120

          Column {
            anchors.fill: parent
            spacing: Style.spacing.xs

            Rectangle {
              width: parent.width
              height: parent.height - titleText.implicitHeight - Style.spacing.xs
              radius: Math.max(2, Math.round(Style.cornerRadius / 2))
              color: Util.alpha(Color.background, 0.6)
              clip: true

              ScreencopyView {
                id: capture
                anchors.fill: parent
                captureSource: preview.open ? thumb.win : null
                live: false
                constraintSize: Qt.size(Math.max(1, width), Math.max(1, height))
                paintCursor: false
                visible: capture.hasContent
              }

              Text {
                anchors.centerIn: parent
                width: parent.width - 8
                visible: !capture.hasContent
                text: thumb.title
                textFormat: Text.PlainText
                font.family: Style.font.resolvedFamily
                font.pixelSize: Math.max(8, Style.font.caption)
                color: Util.alpha(Color.popups.text, 0.75)
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                maximumLineCount: 2
                wrapMode: Text.Wrap
              }
            }

            Text {
              id: titleText
              width: parent.width
              text: thumb.title
              textFormat: Text.PlainText
              font.family: Style.font.resolvedFamily
              font.pixelSize: Style.font.caption
              color: Util.alpha(Color.popups.text, 0.85)
              elide: Text.ElideRight
              horizontalAlignment: Text.AlignHCenter
            }
          }

          HoverHandler { id: thumbHover }
          TapHandler {
            onTapped: {
              if (thumb.win && typeof thumb.win.activate === "function") thumb.win.activate()
              preview.close()
            }
          }
        }
      }
    }
  }
}
