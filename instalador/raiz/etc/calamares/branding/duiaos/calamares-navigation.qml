// SPDX-License-Identifier: GPL-3.0-or-later
// DuiaOS — faixa de baixo do instalador: Voltar e o botão principal (Começar, Continuar, Instalar agora).
import io.calamares.ui 1.0
import io.calamares.core 1.0
import QtQuick

Rectangle {
    id: faixa
    height: 64
    Estilo { id: e }

    readonly property int etapa: ViewManager.currentStepIndex
    readonly property int ultimaConfiguracao: 7          // Revisar (ver calamares-sidebar.qml)
    readonly property bool escura: false
    readonly property bool fim: etapa >= ViewManager.rowCount() - 1

    color: e.fundo

    // Voltar
    Rectangle {
        id: voltar
        anchors.left: parent.left
        anchors.leftMargin: 28
        anchors.verticalCenter: parent.verticalCenter
        visible: ViewManager.backAndNextVisible && faixa.etapa > 0 && !faixa.fim
        enabled: ViewManager.backEnabled
        opacity: enabled ? 1 : 0.4
        width: linhaVoltar.width + 36; height: 42; radius: 21
        color: areaVoltar.pressed ? "#E2E7F8" : (areaVoltar.containsMouse ? "#EAEEFB" : "transparent")
        border.color: faixa.escura ? "#2A3560" : e.borda
        border.width: 1
        Row {
            id: linhaVoltar
            anchors.centerIn: parent
            spacing: 8
            Image { width: 18; height: 18; sourceSize: Qt.size(36, 36); source: "simbolos/voltar.svg"; anchors.verticalCenter: parent.verticalCenter }
            Text {
                text: "Voltar"
                anchors.verticalCenter: parent.verticalCenter
                color: e.texto
                font.family: e.fonteTexto; font.pixelSize: 15; font.weight: Font.DemiBold
            }
        }
        MouseArea { id: areaVoltar; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: ViewManager.back() }
    }

    // Botão principal
    Rectangle {
        id: seguir
        anchors.right: parent.right
        anchors.rightMargin: 28
        anchors.verticalCenter: parent.verticalCenter
        // No fim, o botão fecha o instalador (o "Reiniciar agora" fica na página)
        visible: faixa.fim ? ViewManager.quitVisible : ViewManager.backAndNextVisible
        enabled: faixa.fim ? ViewManager.quitEnabled : ViewManager.nextEnabled
        width: Math.max(150, linhaSeguir.width + 44); height: 44; radius: 22
        opacity: enabled ? 1 : 0.45
        scale: areaSeguir.pressed ? 0.97 : 1
        Behavior on scale { NumberAnimation { duration: 90 } }
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: areaSeguir.containsMouse ? "#0BC4E2" : e.aurora1 }
            GradientStop { position: 0.55; color: areaSeguir.containsMouse ? "#4A66FF" : e.aurora2 }
            GradientStop { position: 1.0; color: areaSeguir.containsMouse ? "#8A4BF2" : e.aurora3 }
        }
        Row {
            id: linhaSeguir
            anchors.centerIn: parent
            spacing: 9
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: faixa.etapa === 0 ? "Começar"
                    : faixa.etapa === faixa.ultimaConfiguracao ? "Instalar agora"
                    : faixa.fim ? "Concluir" : "Continuar"
                color: "#FFFFFF"
                font.family: e.fonteTexto; font.pixelSize: 15; font.weight: Font.Bold
            }
            Image {
                visible: !faixa.fim
                width: 17; height: 17; sourceSize: Qt.size(34, 34)
                anchors.verticalCenter: parent.verticalCenter
                source: "simbolos/seta.svg"
            }
        }
        MouseArea { id: areaSeguir; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: faixa.fim ? ViewManager.quit() : ViewManager.next() }
    }
}
