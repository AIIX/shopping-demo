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
import QtQuick.Controls 2.2
import org.kde.kirigami 2.4 as Kirigami

import Mycroft 1.0 as Mycroft

Mycroft.ScrollableDelegate {
    id: delegate

    property var paymentCartBlob
    property var paymentCartModel: paymentCartBlob.providers
    property var totalPrice

    backgroundImage: "https://source.unsplash.com/1920x1080/?+vegitables"
    graceTime: 80000

    controlBar: RowLayout {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: Kirigami.Units.largeSpacing
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

        Rectangle {
            id: cartBtn
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Kirigami.Theme.backgroundColor
            radius: Kirigami.Units.smallSpacing

            Label {
                id: viewCartLabel
                anchors.centerIn: parent

                text: "Total: " + "£" + totalPrice
            }
        }
    }

    Kirigami.CardsListView {
        model: paymentCartModel

        bottomMargin: delegate.controlBarItem.height + Kirigami.Units.largeSpacing

        delegate: Kirigami.AbstractCard {
            id: aCard
            Layout.fillWidth: true
            implicitHeight: delegateItem.implicitHeight + Kirigami.Units.largeSpacing * 3
            showClickFeedback: true

            contentItem: Item {
                implicitWidth: parent.implicitWidth
                implicitHeight: parent.implicitHeight

                Item {
                    id: delegateItem
                    anchors.left: parent.left
                    anchors.right: parent.right
                    implicitHeight: paymentProviderImage.height + Kirigami.Units.largeSpacing

                    Image {
                        id: paymentProviderImage
                        source: modelData.providerImage
                        anchors.centerIn: parent
                        height: Kirigami.Units.gridUnit * 4
                        width: Kirigami.Units.gridUnit * 4
                        fillMode: Image.PreserveAspectFit
                    }

                }
            }
            onClicked: {
                Mycroft.MycroftController.sendRequest("aiix.shopping-demo.process_payment", {"processor": modelData.providerName});
            }
        }
    }
}

