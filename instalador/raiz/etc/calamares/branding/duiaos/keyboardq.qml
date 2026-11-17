// SPDX-License-Identifier: GPL-3.0-or-later
// DuiaOS — "Teclado": o layout e a variante, com uma linha para testar (o layout muda na hora).
import io.calamares.ui 1.0
import io.calamares.core 1.0
import QtQuick

Pagina {
    id: pagina
    simbolo: "teclado"
    titulo: "Teclado"
    texto: "Escolha o layout das teclas e confira os acentos na linha de teste."
    largura: 860

    Estilo { id: e }
    Nomes { id: nomes }
    property string filtro: ""
    readonly property string layoutAtual: {
        var m = config.keyboardLayoutsModel
        return m && m.currentIndex >= 0 ? String(m.data(m.index(m.currentIndex, 0), 0) || "") : ""
    }

    Column {
        width: parent.width
        spacing: 16

        Rectangle {
            width: parent.width
            height: Math.max(240, Math.min(380, pagina.height - 350))
            radius: e.raioGrande
            color: e.cartao
            border.color: e.borda

            Item {
                anchors.fill: parent
                anchors.margins: 18

                // Procurar
                Rectangle {
                    id: busca
                    width: parent.width; height: 42; radius: 12
                    color: "#F7F8FE"
                    border.color: campoBusca.activeFocus ? e.azul : e.borda
                    border.width: campoBusca.activeFocus ? 2 : 1
                    TextInput {
                        id: campoBusca
                        anchors.fill: parent
                        anchors.leftMargin: 14; anchors.rightMargin: 14
                        verticalAlignment: TextInput.AlignVCenter
                        font.family: e.fonteTexto; font.pixelSize: 15
                        color: e.texto
                        clip: true
                        onTextChanged: pagina.filtro = text.toLowerCase()
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: !parent.text
                            text: "Procurar um layout (ex.: português, inglês)"
                            color: e.textoApagado
                            font: parent.font
                        }
                    }
                }

                Row {
                    anchors.top: busca.bottom; anchors.topMargin: 12
                    anchors.bottom: parent.bottom
                    width: parent.width
                    spacing: 12

                    // Layouts
                    Rectangle {
                        width: parent.width * 0.58; height: parent.height
                        radius: 14; color: "#F7F8FE"; border.color: e.borda; clip: true
                        ListView {
                            id: layouts
                            anchors.fill: parent; anchors.margins: 6
                            model: config.keyboardLayoutsModel
                            currentIndex: model.currentIndex
                            boundsBehavior: Flickable.StopAtBounds
                            spacing: 2
                            delegate: Rectangle {
                                readonly property bool combina: pagina.filtro === "" || String(model.label).toLowerCase().indexOf(pagina.filtro) >= 0
                                    || nomes.teclado(model.label).toLowerCase().indexOf(pagina.filtro) >= 0
                                readonly property bool marcado: index === layouts.model.currentIndex
                                visible: combina
                                width: layouts.width
                                height: combina ? 36 : 0
                                radius: 10
                                color: marcado ? e.azul : (areaLayout.containsMouse ? "#ECEFFC" : "transparent")
                                Text {
                                    anchors.left: parent.left; anchors.leftMargin: 12
                                    anchors.right: parent.right; anchors.rightMargin: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: nomes.teclado(model.label)
                                    elide: Text.ElideRight
                                    color: parent.marcado ? "#FFFFFF" : e.texto
                                    font.family: e.fonteTexto; font.pixelSize: 14
                                    font.weight: parent.marcado ? Font.DemiBold : Font.Normal
                                }
                                MouseArea {
                                    id: areaLayout; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: { layouts.model.currentIndex = index; teste.forceActiveFocus() }
                                }
                            }
                            // Mostra o layout escolhido no meio da lista (quando a lista fica pronta e quando muda)
                            Timer { id: centralizar; interval: 120; onTriggered: layouts.positionViewAtIndex(layouts.model.currentIndex, ListView.Center) }
                            onCountChanged: centralizar.restart()
                            Connections { target: config.keyboardLayoutsModel; function onCurrentIndexChanged() { if (pagina.filtro === "") centralizar.restart() } }
                            Component.onCompleted: centralizar.restart()
                        }
                    }

                    // Variantes
                    Rectangle {
                        width: parent.width * 0.42 - 12; height: parent.height
                        radius: 14; color: "#F7F8FE"; border.color: e.borda; clip: true
                        ListView {
                            id: variantes
                            anchors.fill: parent; anchors.margins: 6
                            model: config.keyboardVariantsModel
                            currentIndex: model.currentIndex
                            boundsBehavior: Flickable.StopAtBounds
                            spacing: 2
                            delegate: Rectangle {
                                readonly property bool marcado: index === variantes.model.currentIndex
                                width: variantes.width
                                height: 36; radius: 10
                                color: marcado ? e.selecao : (areaVariante.containsMouse ? "#ECEFFC" : "transparent")
                                border.color: marcado ? e.azul : "transparent"
                                Text {
                                    anchors.left: parent.left; anchors.leftMargin: 12
                                    anchors.right: parent.right; anchors.rightMargin: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: nomes.variante(model.label, pagina.layoutAtual)
                                    elide: Text.ElideRight
                                    color: e.texto
                                    font.family: e.fonteTexto; font.pixelSize: 14
                                    font.weight: parent.marcado ? Font.DemiBold : Font.Normal
                                }
                                MouseArea {
                                    id: areaVariante; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: { variantes.model.currentIndex = index; teste.forceActiveFocus() }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Testar
        Rectangle {
            width: parent.width; height: 56; radius: 16
            color: e.cartao
            border.color: teste.activeFocus ? e.azul : e.borda
            border.width: teste.activeFocus ? 2 : 1
            TextInput {
                id: teste
                anchors.fill: parent
                anchors.leftMargin: 18; anchors.rightMargin: 18
                verticalAlignment: TextInput.AlignVCenter
                font.family: e.fonteTexto; font.pixelSize: 17
                color: e.texto
                clip: true
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !parent.text
                    text: "Teste aqui: ação, café, pão, você"
                    color: e.textoApagado
                    font: parent.font
                }
            }
        }
    }
}
