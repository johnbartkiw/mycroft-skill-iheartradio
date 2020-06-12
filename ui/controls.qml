import QtQuick.Layouts 1.4
import QtQuick 2.4
import QtQuick.Controls 2.0
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

//
// This is designed and built for a 7" screen, but should resize pretty well regardless of screensize.
// I doubt this would work very well on a Mark2 screen. :(
//
Mycroft.Delegate {
    id: root
    visible: true

    function handlePlayPauseTimer() {
        if(sessionData.audio_state === "playing") {
            refreshTimer.stop()
        } else {
            refreshTimer.start()
        }
        triggerGuiEvent("skill.pause.event", {"click": "CLICK"})
    }

    RowLayout {
        spacing: 2
        anchors.fill: parent
        Column {
            spacing: 2
            Layout.preferredWidth: 0.8*parent.height
            Layout.preferredHeight: parent.height
            Image {
                Layout.alignment: Qt.AlignHCenter
                id: stationImg
                source: Qt.resolvedUrl(sessionData.logoURL)
                width: parent.width
                height: parent.width
                fillMode: Image.PreserveAspectFit
            }
            Rectangle {
                id: stationRect
                anchors.top: stationImg.top
                width: parent.width
                height: parent.width
                color: "transparent"
                border.color: "white"
                border.width: 2
                radius: 20
            }
            Label {
                id: stationDescription
                anchors.top: stationRect.bottom
                width: parent.width
                height: 0.4*(parent.height - parent.width)
                font.bold: true
                font.weight: Font.Bold
                font.pixelSize: .04*parent.height
                text: sessionData.description
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
            Row {
                spacing: 10
                width: parent.width
                anchors.top: stationDescription.bottom
                height: 0.6*(parent.height - parent.width)
                Rectangle {
                    width: 20
                    height: parent.height
                    color: "transparent"
                }
                Image {
                    id: playPauseImg
                    height: parent.height
                    width: parent.height
                    source: Qt.resolvedUrl(sessionData.playPauseImage)
                    MouseArea {
                        anchors.fill: parent
                        id: apause
                        onClicked: { handlePlayPauseTimer() }
                    }
                }
                Rectangle {
                    id: playPauseSpacer
                    anchors.left: playPauseImg.right
                    width: 40
                    height: parent.height
                    color: "transparent"
                }
                Label {
                    id: volumeLabel
                    anchors.left: playPauseSpacer.right
                    font.bold: false
                    font.pixelSize: 10
                    text: "Volume"
                    width: 0.3*parent.width 
                    horizontalAlignment: Text.AlignHCenter
                }
                Slider {
                    id: volumeSlider
                    width: 0.3*parent.width 
                    anchors.left: playPauseSpacer.right
                    anchors.top: volumeLabel.bottom
                    from: 0
                    value: 5
                    to: 10
                    stepSize: 1
                    onMoved: {
                        triggerGuiEvent("skill.volume.event", {"level": volumeSlider.value})
                    }
                }
                CheckBox {
                    id: muteCommercials
                    anchors.left: volumeSlider.right
                    anchors.top: stationDescription.bottom
                    checked: false
                    text: "Mute\nCommercials"
                    onClicked: {
                        triggerGuiEvent("skill.mute.event", {"state": muteCommercials.checked})
                    }
                }
            }
        }
        Column {
            spacing: 0
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height
            Rectangle {
                height: 20
                width: parent.width
                color: "transparent"
            }
            Row {
                spacing: 0
                width: parent.width
                height: (0.5*parent.height)-20
                Rectangle {
                    height: parent.height
                    width: 20
                    color: "transparent"
                }
                Image {
                    id: currentTrackImage
                    source: Qt.resolvedUrl(sessionData.currentTrackImg)
                    width: parent.height-20
                    height: parent.height-20
                }

                Rectangle {
                    height: parent.height
                    width: 20
                    color: "transparent"
                }
                Column {
                    spacing: 5
                    width: parent.width-parent.height-40
                    height: parent.height-20
                    Label {
                        font.pixelSize: .1*parent.height
                        font.bold: true
                        font.weight: Font.Bold
                        text: sessionData.title
                        wrapMode: Text.WordWrap
                        width: parent.width-20
                    }
                    Label {
                        font.bold: false
                        text: sessionData.artist
                        wrapMode: Text.WordWrap
                        width: parent.width-20
                    }
                    Label {
                        font.bold: false
                        text: sessionData.album
                        wrapMode: Text.WordWrap
                        width: parent.width-20
                    }
                }
            }
            Label {
                font.bold: true
                font.pixelSize: 20
                text: " Recently Played"
            }
            Row {
                spacing: 0
                width: parent.width
                height: (0.5*parent.height)-20
                Rectangle {
                    height: parent.height
                    width: 20
                    color: "transparent"
                }
                Column {
                    spacing: 3
                    width: (.33*parent.width)-20
                    height: parent.height
                    Image {
                        id: previous1Img
                        source: Qt.resolvedUrl(sessionData.previous1Img)
                        width: parent.width-20
                        height: parent.width-20
                    }
                    Label {
                        font.bold: true
                        font.pixelSize: 10
                        text: sessionData.previous1Title
                        wrapMode: Text.WordWrap
                        width: parent.width-20
                        lineHeight: 1.0
                    }
                    Label {
                        font.bold: false
                        font.pixelSize: 10
                        text: sessionData.previous1Artist
                        wrapMode: Text.WordWrap
                        width: parent.width-20
                        lineHeight: 1.0
                    }
                    Label {
                        font.bold: false
                        font.pixelSize: 10
                        text: sessionData.previous1Album
                        wrapMode: Text.WordWrap
                        width: parent.width-20
                        lineHeight: 1.0
                    }
                }
                Rectangle {
                    height: parent.height
                    width: 20
                    color: "transparent"
                }
                Column {
                    spacing: 3
                    width: (.33*parent.width)-20
                    height: parent.height
                    Image {
                        id: previous2Img
                        source: Qt.resolvedUrl(sessionData.previous2Img)
                        width: parent.width-20
                        height: parent.width-20
                    }
                    Label {
                        font.bold: true
                        font.pixelSize: 10
                        text: sessionData.previous2Title
                        wrapMode: Text.WordWrap
                        width: parent.width-20
                        lineHeight: 1.0
                    }
                    Label {
                        font.bold: false
                        font.pixelSize: 10
                        text: sessionData.previous2Artist
                        wrapMode: Text.WordWrap
                        width: parent.width-20
                        lineHeight: 1.0
                    }
                    Label {
                        font.bold: false
                        font.pixelSize: 10
                        text: sessionData.previous2Album
                        wrapMode: Text.WordWrap
                        width: parent.width-20
                        lineHeight: 1.0
                    }
                }
                Rectangle {
                    height: parent.height
                    width: 20
                    color: "transparent"
                }
                Column {
                    spacing: 3
                    width: (.33*parent.width)-20
                    height: parent.height
                    Image {
                        id: previous3Img
                        source: Qt.resolvedUrl(sessionData.previous3Img)
                        width: parent.width-20
                        height: parent.width-20
                    }
                    Label {
                        font.bold: true
                        font.pixelSize: 10
                        text: sessionData.previous3Title
                        wrapMode: Text.WordWrap
                        width: parent.width-20
                        lineHeight: 1.0
                    }
                    Label {
                        font.bold: false
                        font.pixelSize: 10
                        text: sessionData.previous3Artist
                        wrapMode: Text.WordWrap
                        width: parent.width-20
                        lineHeight: 1.0
                    }
                    Label {
                        font.bold: false
                        font.pixelSize: 10
                        text: sessionData.previous3Album
                        wrapMode: Text.WordWrap
                        width: parent.width-20
                        lineHeight: 1.0
                    }
                }
            }
        }
    }
    Timer {
        id: refreshTimer
        interval: 10000; running: true; repeat: true
        onTriggered: {
            triggerGuiEvent("skill.timer.event", {"click": "CLICK"})
        }
    }
}
