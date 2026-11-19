import QtQuick
import qs.Commons

// One titled block in the dock's settings popup: a small header (icon + label)
// followed by the caller's controls.
//
// The controls are ordinary children of this Column, so the positioner lays
// them out under the header and the section's implicitHeight follows them.
// The previous wrapper moved its children into a card by hand
// (`children: box.data`), which left every card's height bound to a
// non-bindable implicitHeight: sections collapsed to 28px, the controls spilled
// outside them, and the lower half of the panel was clipped and unreachable.
Column {
  id: root

  property string title: ""
  property string icon: ""

  width: parent ? parent.width : 0
  spacing: Style.spacing.sm

  Row {
    spacing: 8

    Text {
      text: root.icon
      font.pixelSize: 13
      anchors.verticalCenter: parent.verticalCenter
    }
    Text {
      text: root.title
      color: Color.accent
      font.family: Style.font.resolvedFamily
      font.pixelSize: 11
      font.bold: true
      font.letterSpacing: 1.5
      anchors.verticalCenter: parent.verticalCenter
    }
  }
}
