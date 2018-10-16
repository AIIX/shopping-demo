import QtQuick.Layouts 1.4
import QtQuick 2.4
import QtQuick.Controls 2.2
import org.kde.kirigami 2.4 as Kirigami

import Mycroft 1.0 as Mycroft

Mycroft.ScrollableDelegate {
    id: delegate
      property var dataBlob
      property var groceryModel: dataBlob.results
      property var itemCartCount
      backgroundImage: "https://source.unsplash.com/1920x1080/?+vegitables"
      graceTime: 240000
      
    controlBar: RowLayout {
        id: bottomButtonRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        property var itemCnt: delegate.itemCartCount
        
        onItemCntChanged: {
            cartCountLabel.text = itemCartCount
        }
        
        Button {
                id: backButton
                Layout.preferredWidth: parent.width / 6
                Layout.fillHeight: true
                icon.name: "go-previous-symbolic"
                onClicked: {
                    delegate.backRequested();
                }
            }
        
        Button {
        id: cartBtn
        Layout.preferredWidth: parent.width / 2
        Layout.fillHeight: true
        
        Label {
            id: viewCartLabel
            anchors.centerIn: parent
            text: "View Cart"
        }
        
        Rectangle {
            color: Kirigami.Theme.linkColor
            width: Kirigami.Units.gridUnit * 1.5
            height: parent.height - (Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing)
            anchors.right: parent.right
            anchors.rightMargin: Kirigami.Units.largeSpacing
            anchors.verticalCenter: parent.verticalCenter
            radius: 5
            
            Label {
                id: cartCountLabel
                anchors.centerIn: parent
                color: Kirigami.Theme.backgroundColor
                text: "0"
                }
            }
    
        onClicked: {
            Mycroft.MycroftController.sendRequest("aiix.shopping-demo.view_cart", {});
            }
        }
    
    Button {
        id: cartclearBtn
        Layout.preferredWidth: parent.width / 3.225
        Layout.fillHeight: true
        
        Label {
            anchors.centerIn: parent
            text: "Clear Cart"
        }
        
        onClicked: {
            Mycroft.MycroftController.sendText("clear cart")
            }
        }
    }
    
    Kirigami.CardsListView{
        model: groceryModel
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Kirigami.Units.largeSpacing
        anchors.left: parent.left
        anchors.right: parent.right
        clip: true
        delegate: Kirigami.AbstractCard {
        id: aCard
        Layout.fillWidth: true
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
                Layout.fillHeight: true
                Layout.preferredWidth: placeImage.implicitHeight + Kirigami.Units.gridUnit * 2
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
                
                Label {
                    anchors.centerIn: parent
                    text: "Add To Cart"
                }
                onClicked: {
                    Mycroft.MycroftController.sendRequest("aiix.shopping-demo.add_product", {"name": modelData.name});
                            }
                        }
                    }
                }
            }

            Component.onCompleted: {
                Mycroft.MycroftController.sendText("shoppage main")
            }
        }
}
