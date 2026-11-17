// SPDX-License-Identifier: GPL-3.0-or-later
// DuiaOS — "Pronto": o sistema foi instalado (ou o que deu errado, com os detalhes) e o botão para
// reiniciar. Concluir fecha o instalador sem reiniciar.
import io.calamares.ui 1.0
import io.calamares.core 1.0
import QtQuick

Item {
    id: pagina
    Estilo { id: e }

    Rectangle { anchors.fill: parent; color: e.fundo }
    Cartaz {
        anchors.fill: parent
        luz: config.failed ? 0.25 : 0.6

        Column {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -20
            width: Math.min(parent.width - 80, 680)
            spacing: 0

            // Sinal: certo (aurora) ou aviso
            Rectangle {
                id: sinal
                anchors.horizontalCenter: parent.horizontalCenter
                width: 96; height: 96; radius: 48
                scale: 0.6; opacity: 0
                Component.onCompleted: { scale = 1; opacity = 1 }
                Behavior on scale { NumberAnimation { duration: 600; easing.type: Easing.OutBack } }
                Behavior on opacity { NumberAnimation { duration: 400 } }
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: config.failed ? "#E5405E" : e.aurora1 }
                    GradientStop { position: 0.55; color: config.failed ? "#C2304B" : e.aurora2 }
                    GradientStop { position: 1; color: config.failed ? "#9E2238" : e.aurora3 }
                }
                Image {
                    anchors.centerIn: parent
                    visible: !config.failed
                    width: 48; height: 48; sourceSize: Qt.size(96, 96)
                    source: "simbolos/marcado.svg"
                }
                Text {
                    anchors.centerIn: parent
                    visible: config.failed
                    text: "!"
                    color: "#FFFFFF"
                    font.family: e.fonteTitulo; font.pixelSize: 52; font.weight: Font.ExtraBold
                }
            }
            Item { width: 1; height: 30 }
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: config.failed ? "A instalação não terminou" : "O DuiaOS está instalado"
                color: "#FFFFFF"; wrapMode: Text.WordWrap
                font.family: e.fonteTitulo; font.pixelSize: 44; font.weight: Font.ExtraBold; font.letterSpacing: -1
            }
            Item { width: 1; height: 14 }
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: config.failed
                      ? (config.failureMessage || "Algo deu errado durante a instalação.") + " Nada foi apagado além do que a instalação já tinha preparado."
                      : "Reinicie o computador e retire o pendrive (ou a ISO) quando a tela apagar. O Wise vai te receber na primeira entrada."
                color: e.noiteSecundario; wrapMode: Text.WordWrap
                font.family: e.fonteTexto; font.pixelSize: 17; lineHeight: 1.35
            }
            Item { width: 1; height: 26 }
            // Detalhes do erro, para o suporte
            Rectangle {
                visible: config.failed && config.failureDetails !== ""
                width: parent.width; height: Math.min(180, detalhes.implicitHeight + 24); radius: 14
                color: "#121A38"; border.color: "#2A3560"; clip: true
                Flickable {
                    anchors.fill: parent; anchors.margins: 12
                    contentHeight: detalhes.implicitHeight
                    Text { id: detalhes; width: parent.width; text: config.failureDetails; color: "#C9D2F2"; font.family: "monospace"; font.pixelSize: 12; wrapMode: Text.WrapAnywhere }
                }
            }
            Item { width: 1; height: config.failed ? 20 : 4 }
            // Reiniciar agora
            Rectangle {
                visible: !config.failed
                anchors.horizontalCenter: parent.horizontalCenter
                width: rotulo.width + 64; height: 52; radius: 26
                scale: area.pressed ? 0.97 : 1
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: e.aurora1 }
                    GradientStop { position: 0.55; color: e.aurora2 }
                    GradientStop { position: 1; color: e.aurora3 }
                }
                Text {
                    id: rotulo
                    anchors.centerIn: parent
                    text: "Reiniciar agora"
                    color: "#FFFFFF"
                    font.family: e.fonteTexto; font.pixelSize: 17; font.weight: Font.Bold
                }
                MouseArea { id: area; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: config.doRestart(true) }
            }
        }
    }
}
