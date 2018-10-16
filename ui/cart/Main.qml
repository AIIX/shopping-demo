import QtQuick.Layouts 1.4
import QtQuick 2.4
import QtQuick.Controls 2.2
import org.kde.kirigami 2.4 as Kirigami

import Mycroft 1.0 as Mycroft

Mycroft.ScrollableDelegate {
    id: delegate
      property var dataCartBlob
      property var groceryCartModel: dataCartBlob.products
      property var totalPrice
      backgroundImage: "https://source.unsplash.com/1920x1080/?+vegitables"
      graceTime: 80000
    
    controlBar: RowLayout {
        id: bottomButtonRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        property var total: totalPrice
        
        onTotalChanged: {
            viewCartLabel.text = "Total: " + "£" + total + " " + "Checkout"
        }
                
        Button {
            id: backButton
            Layout.preferredWidth: parent.width / 6
            Layout.fillHeight: true
            icon.name: "go-previous-symbolic"
            
            onClicked: {
                delegate.backRequested();
                Mycroft.MycroftController.sendRequest("aiix.shopping-demo.get_product_count", {});
            }
        }
        
        Button {
            id: cartBtn
            Layout.preferredWidth: parent.width / 2
            Layout.fillHeight: true
        
            Label {
                id: viewCartLabel
                anchors.centerIn: parent
            }
        
            onClicked: {
                Mycroft.MycroftController.sendRequest("aiix.shopping-demo.checkout", {});
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
        model: groceryCartModel
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
            
            RowLayout {
                    id: delegateItem
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    spacing: Kirigami.Units.largeSpacing
                
            RowLayout {
                    id: delegateInnerItem
                    Layout.preferredWidth: parent.implicitWidth / 0.75
                    spacing: Kirigami.Units.smallSpacing
            
                    Image {
                        id: placeImage
                        source: modelData.image
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 4
                        Layout.minimumHeight: Kirigami.Units.gridUnit * 4
                        fillMode: Image.PreserveAspectFit
                    }
                    
                    Kirigami.Separator {
                        Layout.fillHeight: true
                        color: Kirigami.Theme.linkColor
                    }
                
                    Label {
                        id: groceryNameLabel
                        Layout.fillWidth: true
                        text: modelData.name
                        wrapMode: Text.WordWrap
                    }
                    
                    Rectangle {
                    id: priceBox
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 2.5
                    Layout.preferredHeight: priceBox.width 
                    color: Kirigami.Theme.linkColor
                    
                    Label {
                        anchors.centerIn: parent
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        text: "£" + modelData.price.toFixed(2);
                        color: Kirigami.Theme.backgroundColor
                        }
                    }
                }
                
                RoundButton {
                    implicitWidth: Kirigami.Units.iconSizes.medium
                    implicitHeight: Kirigami.Units.iconSizes.medium
                    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                    Image {
                        source: "images/removeitem.svg"
                        anchors.centerIn: parent
                        width: Kirigami.Units.iconSizes.medium
                        height: Kirigami.Units.iconSizes.medium
                    }
                    onClicked: {
                        Mycroft.MycroftController.sendRequest("aiix.shopping-demo.remove_product", {"id": modelData.id});
                    }
                }
            }
        }
    }
        
        Component.onCompleted: {
            Mycroft.MycroftController.sendText("shoppage cart")
        }
    }
}

