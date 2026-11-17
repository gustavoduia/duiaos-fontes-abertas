// SPDX-License-Identifier: GPL-3.0-or-later
// DuiaOS — lista de escolha do instalador (regiões e cidades do fuso horário).
import QtQuick

Rectangle {
    id: lista
    property var modelo
    property string escolhido: ""
    property bool mostrarCidade: false
    property var aoEscolher: function(chave) {}
    Estilo { id: e }
    Nomes { id: nomes }
    radius: 14
    color: "#F7F8FE"
    border.color: e.borda
    clip: true
    ListView {
        id: vista
        anchors.fill: parent
        anchors.margins: 6
        model: lista.modelo
        boundsBehavior: Flickable.StopAtBounds
        spacing: 2
        delegate: Rectangle {
            readonly property bool marcado: model.key === lista.escolhido
            width: vista.width
            height: 36; radius: 10
            color: marcado ? e.azul : (areaItem.containsMouse ? "#ECEFFC" : "transparent")
            Text {
                anchors.left: parent.left; anchors.leftMargin: 12
                anchors.right: parent.right; anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: lista.mostrarCidade ? nomes.cidade(model.key) : nomes.regiao(model.key)
                elide: Text.ElideRight
                color: parent.marcado ? "#FFFFFF" : e.texto
                font.family: e.fonteTexto; font.pixelSize: 14
                font.weight: parent.marcado ? Font.DemiBold : Font.Normal
            }
            MouseArea { id: areaItem; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: lista.aoEscolher(model.key) }
        }
        // Mostra o item escolhido no meio da lista (a chave é o papel Qt.UserRole = 256 dos modelos de fuso)
        function mostrarEscolhido() {
            if (!lista.modelo || !lista.modelo.rowCount) return
            for (var i = 0; i < lista.modelo.rowCount(); ++i) {
                if (lista.modelo.data(lista.modelo.index(i, 0), 256) === lista.escolhido) { positionViewAtIndex(i, ListView.Center); return }
            }
        }
        onCountChanged: Qt.callLater(mostrarEscolhido)
        Component.onCompleted: Qt.callLater(mostrarEscolhido)
    }
}
