// SPDX-License-Identifier: GPL-3.0-or-later
// DuiaOS — "Aparência": modo claro, escuro ou automático (o estilo Futurista vem por padrão). A escolha
// vai para o passo "duiaos" pela chave "packagechooser_aparencia" (ver modules/aparencia.conf).
import io.calamares.ui 1.0
import io.calamares.core 1.0
import QtQuick

Pagina {
    id: pagina
    simbolo: "aparencia"
    titulo: "Escolha a aparência"
    texto: "O DuiaOS vem com o estilo Futurista. O modo automático fica claro de dia e escuro à noite."
    largura: 900

    Estilo { id: e }

    property string modo: config.packageChoice || "claro"
    function escolher(valor) { modo = valor; config.packageChoice = valor }

    readonly property var modos: [
        { id: "claro", nome: "Claro", texto: "Fundo claro o dia todo" },
        { id: "escuro", nome: "Escuro", texto: "Fundo azul-noite, descansa a vista" },
        { id: "automatico", nome: "Automático", texto: "Acompanha o dia e a noite" }
    ]

    Row {
        id: linha
        width: parent.width
        spacing: 16
        Repeater {
            model: pagina.modos
            Rectangle {
                readonly property bool marcado: pagina.modo === modelData.id
                width: (linha.width - 32) / 3
                height: amostra.height + 92
                radius: 22
                color: marcado ? e.selecao : (area.containsMouse ? e.cartaoHover : e.cartao)
                border.color: marcado ? e.azul : e.borda
                border.width: marcado ? 2 : 1
                Behavior on color { ColorAnimation { duration: 120 } }

                Amostra {
                    id: amostra
                    x: 12; y: 12
                    width: parent.width - 24
                    height: width * 0.62
                    modo: modelData.id
                }
                Column {
                    anchors.left: parent.left; anchors.leftMargin: 18
                    anchors.right: marca.left; anchors.rightMargin: 10
                    anchors.top: amostra.bottom; anchors.topMargin: 14
                    spacing: 3
                    Text { text: modelData.nome; color: e.texto; font.family: e.fonteTexto; font.pixelSize: 17; font.weight: Font.Bold }
                    Text { width: parent.width; text: modelData.texto; color: e.textoSecundario; font.family: e.fonteTexto; font.pixelSize: 13; wrapMode: Text.WordWrap }
                }
                Rectangle {
                    id: marca
                    anchors.right: parent.right; anchors.rightMargin: 16
                    anchors.top: amostra.bottom; anchors.topMargin: 18
                    width: 24; height: 24; radius: 12
                    color: parent.marcado ? e.azul : "transparent"
                    border.color: parent.marcado ? e.azul : e.bordaForte
                    border.width: 2
                    Image { anchors.centerIn: parent; width: 16; height: 16; sourceSize: Qt.size(32, 32); source: "simbolos/marcado.svg"; visible: parent.parent.marcado }
                }
                MouseArea { id: area; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: pagina.escolher(modelData.id) }
            }
        }
    }
}
