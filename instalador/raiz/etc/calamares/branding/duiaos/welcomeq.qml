// SPDX-License-Identifier: GPL-3.0-or-later
// DuiaOS — boas-vindas do instalador: a Lua ao fundo, o símbolo do DuiaOS e o que falta neste
// computador (se faltar algo, o botão Começar fica desligado e a página diz o porquê).
import io.calamares.ui 1.0
import io.calamares.core 1.0
import QtQuick

Item {
    id: pagina
    Estilo { id: e }

    Rectangle { anchors.fill: parent; color: e.fundo }
    Cartaz {
        anchors.fill: parent

        Column {
            id: centro
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -24
            width: Math.min(parent.width - 80, 820)
            spacing: 0
            opacity: 0
            transform: Translate { id: subida; y: 18 }
            Component.onCompleted: { opacity = 1; subida.y = 0 }
            Behavior on opacity { NumberAnimation { duration: 900; easing.type: Easing.OutCubic } }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 132; height: 132
                sourceSize: Qt.size(264, 264)
                source: "simbolos/logo-aurora.svg"
            }
            Item { width: 1; height: 34 }
            Text {
                width: parent.width
                text: "Boas-vindas ao DuiaOS"
                color: "#FFFFFF"
                font.family: e.fonteTitulo
                font.pixelSize: 54
                font.weight: Font.ExtraBold
                font.letterSpacing: -1.4
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
            Item { width: 1; height: 14 }
            Text {
                width: parent.width
                text: "Vamos preparar este computador. São poucas perguntas, e nada muda no disco antes de você confirmar."
                color: e.noiteSecundario
                font.family: e.fonteTexto
                font.pixelSize: 18
                lineHeight: 1.35
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
            Item { width: 1; height: 34 }

            // O que falta neste computador (requisitos não atendidos)
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                width: Math.min(parent.width, 620)
                Repeater {
                    model: config.unsatisfiedRequirements
                    Rectangle {
                        width: parent.width
                        height: linha.implicitHeight + 26
                        radius: 14
                        color: "#1A2347"
                        border.color: mandatory ? "#7A3A4A" : "#3A4472"
                        Row {
                            id: linha
                            anchors.left: parent.left; anchors.leftMargin: 16
                            anchors.right: parent.right; anchors.rightMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 12
                            Image { width: 20; height: 20; sourceSize: Qt.size(40, 40); source: "simbolos/aviso.svg"; anchors.verticalCenter: parent.verticalCenter }
                            Text {
                                width: parent.width - 32
                                anchors.verticalCenter: parent.verticalCenter
                                text: negatedText
                                color: "#E9EDFF"
                                font.family: e.fonteTexto
                                font.pixelSize: 14
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }
            }
        }

        Text {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 22
            anchors.horizontalCenter: parent.horizontalCenter
            text: Branding.string(Branding.VersionedName) + ", baseado no Debian 13"
            color: "#6F7AA3"
            font.family: e.fonteTexto
            font.pixelSize: 13
        }
    }
}
