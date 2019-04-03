/*
 *  Copyright 2018 by Aditya Mehra <aix.m@outlook.com>
 *  Copyright 2018 Marco Martin <mart@kde.org>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import QtQuick.Layouts 1.4
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.2
import org.kde.kirigami 2.4 as Kirigami

import Mycroft 1.0 as Mycroft

Mycroft.ScrollableDelegate {
    id: delegate

    property var groceryModel: sessionData.dataBlob.results
    property var multipleProductsAddBlob: sessionData.multipleProductsAddBlob 
    property var itemCartCount: sessionData.itemCartCount

    skillBackgroundSource: "https://source.unsplash.com/1920x1080/?+vegitables"
    //graceTime: 240000

    onMultipleProductsAddBlobChanged: {
        if (multipleProductsAddBlob.results && multipleProductsAddBlob.results.length > 0) {
            multipleProductsAddSheet.open();
        } else {
            multipleProductsAddSheet.close();
        }
    }

    controlBar: Control {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        padding: Kirigami.Units.largeSpacing

        background: LinearGradient {
            start: Qt.point(0, 0)
            end: Qt.point(0, height)
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: "black" }
            }
        }

        contentItem: RowLayout {
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
                text: "View Cart"
                enabled: itemCartCount > 0

                //Badge
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
                        text: delegate.itemCartCount
                    }
                }

                onClicked: {
                    triggerGuiEvent("aiix.shopping-demo.view_cart", {});
                }
            }

            Button {
                id: cartclearBtn
                Layout.preferredWidth: parent.width / 3.225
                Layout.fillHeight: true

                text: "Clear Cart"

                onClicked: {
                    triggerGuiEvent("aiix.shopping-demo.clear_cart", {});
                }
            }
        }
    }

    Kirigami.CardsGridView {
        model: groceryModel

        bottomMargin: delegate.controlBarItem.height + Kirigami.Units.largeSpacing

        minimumColumnWidth: Kirigami.Units.gridUnit * 25
        maximumColumnWidth: Kirigami.Units.gridUnit * 35
        cellHeight: contentItem.children[0].implicitHeight + Kirigami.Units.gridUnit

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
                            Label {
                                Kirigami.FormData.label: "Department:"
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                                text: modelData.department
                            }

                            Label {
                                Kirigami.FormData.label: "Qty:"
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                                text: modelData.ContentsQuantity + " " + modelData.ContentsMeasureType
                            }

                            Label {
                                Kirigami.FormData.label: "Price:"
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                                text: "£" + modelData.price
                            }
                        }
                    }

                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 2
                        text: "Add To Cart"

                        onClicked: {
                            console.log(modelData.name);
                            triggerGuiEvent("aiix.shopping-demo.add_product", {"name": modelData.name});
                        }
                    }
                }
            }
        }

        Component.onCompleted: {
            Mycroft.MycroftController.sendText("shoppage main")
        }
    }

    Kirigami.OverlaySheet {
        id: multipleProductsAddSheet

        leftPadding: 0
        rightPadding: 0

        parent: delegate
        header: Kirigami.Heading {
            text: "Select Product:"
        }
        ColumnLayout {
            implicitWidth: Kirigami.Units.gridUnit * 25
            spacing: 0
            Repeater {
                model: multipleProductsAddBlob.results
                delegate: Kirigami.AbstractListItem {
                    width: parent.width
                    onClicked: {
                        triggerGuiEvent("aiix.shopping-demo.add_product", {"name": modelData.name});
                        multipleProductsAddSheet.close();
                    }
                    RowLayout {
                        Kirigami.Heading {
                            text: index
                        }
                        Image {
                            source: modelData.image
                            Layout.fillHeight: true
                            Layout.preferredWidth: placeImage.implicitHeight + Kirigami.Units.gridUnit * 2
                            fillMode: Image.PreserveAspectFit
                        }
                        Kirigami.Heading {
                            Layout.fillWidth: true
                            text: modelData.name
                            level: 3
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }
    }
}
