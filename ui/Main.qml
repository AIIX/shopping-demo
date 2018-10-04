import QtQuick.Layouts 1.4
import QtQuick 2.4
import QtQuick.Controls 2.2
import org.kde.kirigami 2.4 as Kirigami
import org.kde.plasma.core 2.1 as PlasmaCore

import Mycroft 1.0 as Mycroft

Mycroft.ScrollableDelegate {
    id: delegate
      property var dataBlob
      property var groceryModel: dataBlob.results
      backgroundImage: "https://source.unsplash.com/1920x1080/?+vegitables"
      graceTime: 30000
        
    Kirigami.CardsListView{
        model: groceryModel
        delegate: Kirigami.AbstractCard {
        id: aCard
        implicitHeight: delegateItem.implicitHeight + Kirigami.Units.largeSpacing * 3
        
        contentItem: Item {
            implicitWidth: parent.implicitWidth
            implicitHeight: parent.implicitHeight
            
        ColumnLayout {
                id: delegateItem
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: Kirigami.Units.smallSpacing
             
            Kirigami.Heading {
                id: groceryNameLabel
                Layout.fillWidth: true
                text: modelData.name
                level: 3
                wrapMode: Text.WordWrap
            }
        
            Kirigami.Separator {
                Layout.fillWidth: true
                color: Kirigami.Theme.linkColor
            }
        
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: form.implicitHeight
        
            Image {
                id: placeImage
                source: modelData.image
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 4
                Layout.minimumHeight: Kirigami.Units.gridUnit * 4
                fillMode: Image.PreserveAspectFit
            }
            
            Kirigami.Separator {
                Layout.fillHeight: true
                color: Kirigami.Theme.linkColor
            }
                                            
            Kirigami.FormLayout {
                id: form
                Layout.fillWidth: true
                Layout.minimumWidth: aCard.implicitWidth
                Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                                                    
                Label {
                    Kirigami.FormData.label: "Description:"
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    text: modelData.superDepartment
                }
                
                Kirigami.Separator {
                    Layout.fillWidth: true
                    color: Kirigami.Theme.textColor
                }
                
                Label {
                    Kirigami.FormData.label: "Department:"
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    text: modelData.department
                }
                
                Kirigami.Separator {
                    Layout.fillWidth: true
                    color: Kirigami.Theme.textColor
                }
                
                Label {
                    Kirigami.FormData.label: "Qty:"
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    text: modelData.ContentsQuantity + " " + modelData.ContentsMeasureType
                }
                
                Kirigami.Separator {
                    Layout.fillWidth: true
                    color: Kirigami.Theme.textColor
                }
                
                Label {
                    Kirigami.FormData.label: "Price:"
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    width: rater.width
                    text: "£" + modelData.price
                }
                
                Kirigami.Separator {
                    Layout.fillWidth: true
                    color: Kirigami.Theme.textColor
                    }
                }
            }
            
            Kirigami.Separator {
                    Layout.fillWidth: true
                    color: Kirigami.Theme.linkColor
            }
            
            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 2
                text: "Add To Cart"
            }
        }
    }
}
}
}
