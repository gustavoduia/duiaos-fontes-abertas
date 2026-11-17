// SPDX-License-Identifier: GPL-3.0-or-later
// DuiaOS — molde das páginas do instalador: um símbolo, o título, uma frase e o conteúdo, numa
// coluna centrada (como o Assistente de Configuração do macOS). O conteúdo rola se não couber.
import QtQuick

Item {
    id: pagina
    property string simbolo: ""          // arquivo em simbolos/ (sem .svg)
    property Component topo: null        // no lugar do símbolo (ex.: a foto da conta)
    property string titulo: ""
    property string texto: ""
    property int largura: 760            // largura máxima do conteúdo
    default property alias conteudo: area.data

    function rolarParaOFim() {
        animacaoRolagem.to = Math.max(0, rolagem.contentHeight - rolagem.height)
        animacaoRolagem.start()
    }

    Estilo { id: e }

    Rectangle { anchors.fill: parent; color: e.fundo }
    Image {
        // brilho aurora bem suave atrás do título
        source: "brilho.png"
        width: Math.min(parent.width, 1400); height: width * 0.32
        anchors.horizontalCenter: parent.horizontalCenter
        y: -height * 0.38
        opacity: 0.85
        fillMode: Image.Stretch
    }

    Flickable {
        id: rolagem
        anchors.fill: parent
        contentWidth: width
        contentHeight: Math.max(height, coluna.implicitHeight + 64)
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        NumberAnimation on contentY { id: animacaoRolagem; running: false; duration: 380; easing.type: Easing.OutCubic }

        Column {
            id: coluna
            width: Math.min(pagina.largura, rolagem.width - 64)
            anchors.horizontalCenter: parent.horizontalCenter
            y: Math.max(28, (rolagem.height - implicitHeight) * 0.32)
            spacing: 0

            Rectangle {
                visible: pagina.simbolo !== ""
                width: 64; height: 64; radius: 20
                anchors.horizontalCenter: parent.horizontalCenter
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: e.aurora1 }
                    GradientStop { position: 0.55; color: e.aurora2 }
                    GradientStop { position: 1.0; color: e.aurora3 }
                }
                Image {
                    anchors.centerIn: parent
                    width: 34; height: 34
                    sourceSize: Qt.size(68, 68)
                    source: pagina.simbolo !== "" ? "simbolos/" + pagina.simbolo + ".svg" : ""
                }
            }
            Loader {
                active: pagina.topo !== null
                anchors.horizontalCenter: parent.horizontalCenter
                sourceComponent: pagina.topo
            }
            Item { width: 1; height: pagina.simbolo !== "" || pagina.topo !== null ? 22 : 0 }
            Text {
                width: parent.width
                text: pagina.titulo
                color: e.texto
                font.family: e.fonteTitulo
                font.pixelSize: 34
                font.weight: Font.ExtraBold
                font.letterSpacing: -0.6
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
            Item { width: 1; height: 10 }
            Text {
                visible: pagina.texto !== ""
                width: Math.min(parent.width, 600)
                anchors.horizontalCenter: parent.horizontalCenter
                text: pagina.texto
                color: e.textoSecundario
                font.family: e.fonteTexto
                font.pixelSize: 16
                lineHeight: 1.35
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
            Item { width: 1; height: 30 }
            Item {
                id: area
                width: parent.width
                implicitHeight: childrenRect.height
                height: implicitHeight
            }
        }
    }
}
