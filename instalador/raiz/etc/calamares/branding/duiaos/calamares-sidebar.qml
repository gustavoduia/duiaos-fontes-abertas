// SPDX-License-Identifier: GPL-3.0-or-later
// DuiaOS — faixa do alto do instalador: o símbolo do DuiaOS, o andamento das etapas e "Cancelar".
import io.calamares.ui 1.0
import io.calamares.core 1.0
import QtQuick

Rectangle {
    id: faixa
    height: 64
    Estilo { id: e }

    // As etapas, na ordem de settings.conf (as páginas mostradas, a instalação e o fim)
    readonly property var nomes: ["Boas-vindas", "Idioma e região", "Teclado", "Disco", "Sua conta",
                                  "Programas", "Aparência", "Revisar", "Instalação", "Pronto"]
    readonly property int etapa: ViewManager.currentStepIndex
    readonly property int primeira: 1                 // primeira etapa de configuração
    readonly property int ultima: 7                   // Revisar
    readonly property bool configurando: etapa >= primeira && etapa <= ultima
    readonly property bool escura: false

    color: e.fundo

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 28
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10
        opacity: faixa.etapa === 0 ? 0 : 1            // nas boas-vindas o símbolo grande já está na página
        Behavior on opacity { NumberAnimation { duration: 300 } }
        Image {
            width: 26; height: 26
            sourceSize: Qt.size(52, 52)
            anchors.verticalCenter: parent.verticalCenter
            source: faixa.escura ? "simbolos/logo-aurora.svg" : "simbolos/logo.svg"
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "DuiaOS"
            color: faixa.escura ? e.noiteTexto : "#16205C"
            font.family: e.fonteTitulo
            font.pixelSize: 18
            font.weight: Font.ExtraBold
            font.letterSpacing: -0.3
        }
    }

    // Andamento: o nome da etapa e um traço por etapa de configuração
    Column {
        anchors.centerIn: parent
        spacing: 9
        visible: faixa.configurando
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: (faixa.nomes[faixa.etapa] || "") + "   " + (faixa.etapa - faixa.primeira + 1) + " de " + (faixa.ultima - faixa.primeira + 1)
            color: e.textoSecundario
            font.family: e.fonteTexto
            font.pixelSize: 13
            font.weight: Font.DemiBold
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 6
            Repeater {
                model: faixa.ultima - faixa.primeira + 1
                Rectangle {
                    readonly property int numero: index + faixa.primeira
                    width: numero === faixa.etapa ? 44 : 26
                    height: 4; radius: 2
                    color: numero <= faixa.etapa ? e.azul : e.borda
                    Behavior on width { NumberAnimation { duration: e.animacao; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: e.animacao } }
                }
            }
        }
    }

    // Cancelar: o próprio instalador pergunta se a pessoa quer mesmo sair
    Text {
        id: cancelar
        anchors.right: parent.right
        anchors.rightMargin: 28
        anchors.verticalCenter: parent.verticalCenter
        visible: ViewManager.quitVisible && faixa.etapa <= faixa.ultima
        text: "Cancelar"
        color: area.containsMouse ? (faixa.escura ? "#FFFFFF" : e.texto) : (faixa.escura ? e.noiteSecundario : e.textoSecundario)
        font.family: e.fonteTexto
        font.pixelSize: 14
        font.weight: Font.Medium
        MouseArea {
            id: area
            anchors.fill: parent
            anchors.margins: -10
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            enabled: ViewManager.quitEnabled
            onClicked: ViewManager.quit()
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width; height: 1
        color: e.borda
        opacity: 0
    }

    // No Wayland, a faixa não se redesenha sozinha quando a página em widgets (o disco) entra; um ponto
    // invisível que muda duas vezes por segundo força o redesenho (custa quase nada)
    Rectangle {
        id: pulso
        width: 1; height: 1; color: "transparent"; opacity: 0
        Timer { interval: 500; running: true; repeat: true; onTriggered: pulso.opacity = pulso.opacity > 0 ? 0 : 0.01 }
    }
}
