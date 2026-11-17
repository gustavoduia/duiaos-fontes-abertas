// SPDX-License-Identifier: GPL-3.0-or-later
// DuiaOS — enquanto o sistema é instalado: o símbolo do DuiaOS com o ponto em órbita e, embaixo, uma
// frase por vez sobre o que vem no sistema. A barra de andamento fica logo abaixo (do instalador).
import QtQuick

Item {
    id: tela
    anchors.fill: parent
    property int atual: 0
    Estilo { id: e }

    readonly property var frases: [
        { titulo: "Instalando o DuiaOS", texto: "Isso leva alguns minutos. Pode deixar o computador trabalhando." },
        { titulo: "O Wise já vem com o sistema", texto: "Peça em português, por texto ou por voz: instalar um programa, achar um arquivo, ver a agenda. Ele pede a sua aprovação antes de mudar qualquer coisa." },
        { titulo: "A IA roda no seu computador", texto: "O modelo de IA local fica no próprio computador. Nada sai dele, a não ser que você ligue um motor na nuvem." },
        { titulo: "Do seu jeito", texto: "Modo claro, escuro ou automático, a Ilha de Aplicativos e os menus dos aplicativos na barra do alto." },
        { titulo: "Sempre em dia", texto: "O DuiaOS procura atualizações sozinho e explica, em português, o que cada uma muda." }
    ]
    function onActivate() { troca.restart() }
    function onLeave() { troca.stop() }

    Rectangle { anchors.fill: parent; color: e.fundo }
    Cartaz {
        anchors.fill: parent
        luz: 0.45

        // Símbolo com o ponto girando em volta
        Item {
            id: simbolo
            width: 220; height: 220
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -70
            Rectangle {
                anchors.centerIn: parent
                width: 200; height: 200; radius: 100
                color: "transparent"
                border.color: "#2A3A7A"; border.width: 1
                opacity: 0.7
            }
            Image {
                anchors.centerIn: parent
                width: 104; height: 104
                sourceSize: Qt.size(208, 208)
                source: "simbolos/logo-sem-ponto.svg"
                opacity: 0.95
            }
            Item {
                anchors.fill: parent
                RotationAnimator on rotation { from: 0; to: 360; duration: 3600; loops: Animation.Infinite; running: true }
                Rectangle {
                    x: parent.width / 2 - 7; y: 3
                    width: 14; height: 14; radius: 7
                    gradient: Gradient {
                        GradientStop { position: 0; color: "#7DF3FF" }
                        GradientStop { position: 1; color: "#3D7BFF" }
                    }
                }
            }
        }

        Column {
            id: caixa
            anchors.top: simbolo.bottom; anchors.topMargin: 34
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(parent.width - 80, 640)
            spacing: 12
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: tela.frases[tela.atual].titulo
                color: "#FFFFFF"; wrapMode: Text.WordWrap
                font.family: e.fonteTitulo; font.pixelSize: 32; font.weight: Font.ExtraBold; font.letterSpacing: -0.6
            }
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: tela.frases[tela.atual].texto
                color: e.noiteSecundario; wrapMode: Text.WordWrap
                font.family: e.fonteTexto; font.pixelSize: 16; lineHeight: 1.35
            }
        }
        Row {
            anchors.bottom: parent.bottom; anchors.bottomMargin: 26
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 6
            Repeater {
                model: tela.frases.length
                Rectangle {
                    width: index === tela.atual ? 22 : 7; height: 7; radius: 3.5
                    color: index === tela.atual ? "#FFFFFF" : "#4DFFFFFF"
                    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                }
            }
        }
    }

    SequentialAnimation {
        id: passagem
        NumberAnimation { target: caixa; property: "opacity"; to: 0; duration: 260 }
        ScriptAction { script: tela.atual = (tela.atual + 1) % tela.frases.length }
        NumberAnimation { target: caixa; property: "opacity"; to: 1; duration: 420 }
    }
    Timer { id: troca; interval: 9000; repeat: true; running: true; onTriggered: passagem.restart() }
}
