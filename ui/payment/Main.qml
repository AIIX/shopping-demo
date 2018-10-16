import QtQuick.Layouts 1.4
import QtQuick 2.4
import QtQuick.Controls 2.2
import org.kde.kirigami 2.4 as Kirigami
import org.kde.plasma.core 2.1 as PlasmaCore

import Mycroft 1.0 as Mycroft

Mycroft.DelegateBase {
    id: paymentDelegate
      property var userAddress
      backgroundImage: "https://source.unsplash.com/1920x1080/?+gradient"
      graceTime: 80000
    
    controlBar: RowLayout {
        id: bottomButtonRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    
        Button {
            id: backButton
            Layout.preferredWidth: parent.width / 6
            Layout.fillHeight: true
            icon.name: "go-previous-symbolic"
            
            onClicked: {
                paymentDelegate.backRequested();
            }
        }
    }
    
    Flickable {
        anchors.fill: parent
        contentHeight: layout.height
        topMargin: Math.max(0, (height - contentHeight)/2)

        ColumnLayout {
            id: layout
            width: parent
            spacing: Kirigami.Units.largeSpacing
            
        Kirigami.Heading {
            id: messageHeader
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            level: 1
            text: "Payment Completed"
        }
            
        Kirigami.Heading {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            level: 3
            text: "Thank You " + userAddress.Fullname
        }
        
        Kirigami.FormLayout {
                id: form
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                                                    
                Label {
                    Kirigami.FormData.label: "Street:"
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    text: userAddress.Street
                }
                
                Kirigami.Separator {
                    Layout.fillWidth: true
                    color: Kirigami.Theme.textColor
                }
                
                Label {
                    Kirigami.FormData.label: "City:"
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    text: userAddress.City
                }
                
                Kirigami.Separator {
                    Layout.fillWidth: true
                    color: Kirigami.Theme.textColor
                }
                
                Label {
                    Kirigami.FormData.label: "Zip Code:"
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    text: userAddress.Zip
                }
                
                Kirigami.Separator {
                    Layout.fillWidth: true
                    color: Kirigami.Theme.textColor
                }
                
                Label {
                    Kirigami.FormData.label: "Phone:"
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    text: userAddress.Phone
                }
                
                Kirigami.Separator {
                    Layout.fillWidth: true
                    color: Kirigami.Theme.textColor
                    }
                }
        }
    }
}

