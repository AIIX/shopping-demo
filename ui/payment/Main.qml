/*
 *  Copyright 2018 by Aditya Mehra <aix.m@outlook.com>
 *  Copyright 2018 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.4
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.2
import org.kde.kirigami 2.4 as Kirigami

import Mycroft 1.0 as Mycroft

Mycroft.ScrollableDelegate {
    id: paymentDelegate

    property var userAddress

    backgroundImage: "https://source.unsplash.com/1920x1080/?+gradient"
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
                paymentDelegate.backRequested();
            }
        }
    }

    Flickable {
        anchors.fill: parent

        contentHeight: layout.height

        topMargin: Math.max(0, (height - contentHeight)/2)
        bottomMargin: delegate.controlBarItem.height + Kirigami.Units.largeSpacing

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

