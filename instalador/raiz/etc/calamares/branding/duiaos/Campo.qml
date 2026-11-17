// SPDX-License-Identifier: GPL-3.0-or-later
// DuiaOS — campo de texto do instalador: rótulo, caixa e uma linha de ajuda ou de erro.
import QtQuick

Column {
    id: campo
    property string rotulo: ""
    property string dica: ""                 // texto apagado dentro da caixa vazia
    property string ajuda: ""                // linha embaixo (cinza)
    property string erro: ""                 // linha embaixo (vermelha), tem prioridade
    property bool senha: false
    property alias texto: entrada.text
    property alias entrada: entrada
    signal editado(string texto)

    Estilo { id: e }
    spacing: 7

    Text {
        text: campo.rotulo
        color: e.texto
        font.family: e.fonteTexto; font.pixelSize: 14; font.weight: Font.DemiBold
    }
    Rectangle {
        width: campo.width; height: 48; radius: 14
        color: e.cartao
        border.color: campo.erro !== "" ? e.erro : (entrada.activeFocus ? e.azul : e.borda)
        border.width: entrada.activeFocus || campo.erro !== "" ? 2 : 1
        Behavior on border.color { ColorAnimation { duration: 120 } }
        TextInput {
            id: entrada
            anchors.fill: parent
            anchors.leftMargin: 16; anchors.rightMargin: campo.senha ? 52 : 16
            verticalAlignment: TextInput.AlignVCenter
            font.family: e.fonteTexto; font.pixelSize: 16
            color: e.texto
            selectionColor: e.azul
            clip: true
            echoMode: campo.senha && !mostrar.ativo ? TextInput.Password : TextInput.Normal
            passwordCharacter: "•"
            onTextEdited: campo.editado(text)
            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: !parent.text && !parent.activeFocus
                text: campo.dica
                color: e.textoApagado
                font.family: e.fonteTexto; font.pixelSize: 16
            }
        }
        // Mostrar a senha
        Text {
            id: mostrar
            property bool ativo: false
            visible: campo.senha
            anchors.right: parent.right; anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            text: ativo ? "Ocultar" : "Mostrar"
            color: e.azul
            font.family: e.fonteTexto; font.pixelSize: 13; font.weight: Font.DemiBold
            MouseArea { anchors.fill: parent; anchors.margins: -8; cursorShape: Qt.PointingHandCursor; onClicked: mostrar.ativo = !mostrar.ativo }
        }
    }
    Text {
        width: campo.width
        visible: text !== ""
        text: campo.erro !== "" ? campo.erro : campo.ajuda
        color: campo.erro !== "" ? e.erro : e.textoSecundario
        font.family: e.fonteTexto; font.pixelSize: 13
        wrapMode: Text.WordWrap
    }
}
