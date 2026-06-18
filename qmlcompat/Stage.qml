import QtQuick 2.3

// Host stage for the simulator. The selected dash (an 800x480 Item that binds
// to the global "rpmtest" context property) is loaded into the Loader below and
// scaled to fit the view while preserving aspect ratio. Letterbox stays black.
Rectangle {
    id: root
    color: "#000000"
    property url dashSource: ""

    // Reload helper invoked from Python when the dash selection changes.
    function setDash(src) {
        if (loader.source == src) {
            loader.source = "";   // force a fresh reload of the same dash
        }
        root.dashSource = src;
        loader.source = src;
    }

    Item {
        id: stage
        width: 800
        height: 480
        anchors.centerIn: parent
        scale: Math.min(root.width / 800, root.height / 480)
        transformOrigin: Item.Center

        Loader {
            id: loader
            anchors.fill: parent
            asynchronous: false
            source: root.dashSource
            onStatusChanged: {
                if (status === Loader.Error)
                    console.log("Dash load error for " + root.dashSource);
            }
        }

        // Visible diagnostic if a dash fails to load (e.g. a missing QML
        // module) instead of a silent black screen.
        Column {
            anchors.centerIn: parent
            width: parent.width - 80
            spacing: 10
            visible: loader.status === Loader.Error
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                color: "#ff6b6b"
                font.pixelSize: 22
                text: "This dash failed to load"
            }
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                color: "#c2c8d2"
                font.pixelSize: 14
                text: root.dashSource + "\n\nCheck the terminal for the QML error. " +
                      "A 'module ... is not installed' message usually means a " +
                      "full PySide6 install is needed:  pip install PySide6"
            }
        }
    }

    // Subtle frame so the active render area is obvious inside the widget.
    Rectangle {
        anchors.fill: stage
        anchors.margins: -1
        color: "transparent"
        border.color: "#1e2430"
        border.width: 1
        scale: stage.scale
        transformOrigin: Item.Center
        visible: loader.status === Loader.Ready
    }
}
