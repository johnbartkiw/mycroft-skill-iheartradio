import QtQuick.Layouts 1.4
import QtQuick 2.4
import QtQuick.Controls 2.0
import org.kde.kirigami 2.4 as Kirigami

import Mycroft 1.0 as Mycroft


Mycroft.Delegate {
    id: root
    property var album_img: sessionData.image
    ColumnLayout {
        spacing: 2
        anchors.centerIn: parent
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter

        RowLayout {
            id: stationGrid
            Layout.fillWidth: true
            Image {
                Layout.alignment: Qt.AlignHCenter
                id: img
                source: Qt.resolvedUrl(sessionData.logoURL)
                Layout.preferredWidth: 300
                Layout.preferredHeight: 350
                fillMode: Image.PreserveAspectFit
            }
            Kirigami.Label {
                id: description
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                font.family: "Noto Sans"
                font.bold: true
                font.weight: Font.Bold
                font.pixelSize: 30
                text: sessionData.description
            }
        }
        RowLayout {
            id: trackGrid
            Layout.fillWidth: true
            Image {
                Layout.alignment: Qt.AlignHCenter
                id: trackimg
                source: Qt.resolvedUrl(sessionData.currentTrackImg)
                Layout.preferredWidth: 200
                Layout.preferredHeight: 200
                fillMode: Image.PreserveAspectFit
            }
            ColumnLayout {
                spacing: 1
                Layout.alignment: Qt.AlignHCenter

                Kirigami.Label {
                    id: currentTrackTitle
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    horizontalAlignment: Text.AlignHLeft
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    font.family: "Noto Sans"
                    font.bold: true
                    font.weight: Font.Bold
                    font.pixelSize: 25
                    text: sessionData.title
                }
                Kirigami.Label {
                    id: currentTrackArtist
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    horizontalAlignment: Text.AlignHLeft
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    font.family: "Noto Sans"
                    font.bold: false
                    font.pixelSize: 20
                    text: sessionData.artist
                }
                Kirigami.Label {
                    id: currentTrackAlbum
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    horizontalAlignment: Text.AlignHLeft
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    font.family: "Noto Sans"
                    font.bold: false
                    font.pixelSize: 20
                    text: sessionData.album
                }
            }
        }
        RowLayout {
            id: grid
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom

            Image {
                height: 200
                source: Qt.resolvedUrl(sessionData.playPauseImage)
                opacity: apause.pressed ? 0.5 : 1.0
                MouseArea {
                    id: apause
                    anchors.fill: parent
                    onClicked: triggerGuiEvent("skill.pause.event", {"click": "CLICK"})
                }
            }
        }
    }
    Timer {
        interval: 10000; running: true; repeat: true
        onTriggered: triggerGuiEvent("skill.timer.event", {"click": "CLICK"})
    }
    
}
