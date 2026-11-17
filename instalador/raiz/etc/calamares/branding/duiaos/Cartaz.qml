// SPDX-License-Identifier: GPL-3.0-or-later
// DuiaOS — os momentos escuros do instalador (boas-vindas, instalação, fim): um cartaz de cantos
// redondos com a Lua ao fundo, sobre o fundo claro das faixas.
import QtQuick
import QtQuick.Effects

Item {
    id: cartaz
    property real luz: 0.62                 // quanto a foto aparece
    property bool foto: true
    default property alias conteudo: dentro.data

    Estilo { id: e }

    Item {
        id: arte
        anchors.fill: parent
        anchors.margins: 6
        visible: false
        layer.enabled: true
        Rectangle { anchors.fill: parent; color: e.noite }
        Image {
            anchors.fill: parent
            visible: cartaz.foto
            source: "lua.jpg"
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            opacity: status === Image.Ready ? cartaz.luz : 0
            Behavior on opacity { NumberAnimation { duration: 1400; easing.type: Easing.OutCubic } }
        }
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#B0070B18" }
                GradientStop { position: 0.45; color: "#38070B18" }
                GradientStop { position: 1.0; color: "#F2070B18" }
            }
        }
    }
    Item {
        id: mascara
        anchors.fill: arte
        visible: false
        layer.enabled: true
        Rectangle { anchors.fill: parent; radius: 26; color: "black" }
    }
    MultiEffect {
        anchors.fill: arte
        source: arte
        maskEnabled: true
        maskSource: mascara
    }
    Item {
        id: dentro
        anchors.fill: arte
    }
}
