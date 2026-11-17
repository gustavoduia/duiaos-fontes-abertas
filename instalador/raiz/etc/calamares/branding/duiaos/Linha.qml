// SPDX-License-Identifier: GPL-3.0-or-later
// DuiaOS — uma linha do resumo do instalador: o assunto e o que vai acontecer.
import QtQuick

Rectangle {
    id: linha
    property string rotulo: ""
    property string valor: ""
    property string simbolo: ""
    property bool rico: false               // o texto vem do instalador, com marcações (negrito)
    property bool destaque: false           // o que não dá para desfazer (o disco)
    Estilo { id: e }

    width: parent ? parent.width : 600
    implicitHeight: Math.max(64, coluna.implicitHeight + 30)
    height: implicitHeight
    radius: 18
    color: destaque ? "#FFF8EC" : e.cartao
    border.color: destaque ? "#F1C77A" : e.borda

    Rectangle {
        id: icone
        anchors.left: parent.left; anchors.leftMargin: 16
        anchors.top: parent.top; anchors.topMargin: 15
        width: 34; height: 34; radius: 11
        color: e.selecao
        Text {
            anchors.centerIn: parent
            visible: linha.simbolo === ""
            text: linha.rotulo.length ? linha.rotulo[0].toUpperCase() : ""
            color: e.azul
            font.family: e.fonteTitulo; font.pixelSize: 15; font.weight: Font.ExtraBold
        }
        Rectangle {
            anchors.fill: parent; radius: 11
            visible: linha.simbolo !== ""
            gradient: Gradient { orientation: Gradient.Horizontal
                GradientStop { position: 0; color: e.aurora1 } GradientStop { position: 0.55; color: e.aurora2 } GradientStop { position: 1; color: e.aurora3 } }
            Image { anchors.centerIn: parent; width: 18; height: 18; sourceSize: Qt.size(36, 36); source: linha.simbolo !== "" ? "simbolos/" + linha.simbolo + ".svg" : "" }
        }
    }
    Column {
        id: coluna
        anchors.left: icone.right; anchors.leftMargin: 14
        anchors.right: parent.right; anchors.rightMargin: 18
        anchors.top: parent.top; anchors.topMargin: 14
        spacing: 3
        Text { text: linha.rotulo; color: e.texto; font.family: e.fonteTexto; font.pixelSize: 15; font.weight: Font.DemiBold }
        Text {
            width: parent.width
            text: linha.valor
            textFormat: linha.rico ? Text.StyledText : Text.PlainText
            color: e.textoSecundario
            font.family: e.fonteTexto; font.pixelSize: 14
            lineHeight: 1.3
            wrapMode: Text.WordWrap
        }
    }
}
