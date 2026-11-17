// SPDX-License-Identifier: GPL-3.0-or-later
// DuiaOS — "Idioma e região": o idioma do sistema e o fuso horário (padrão: Brasília).
import io.calamares.ui 1.0
import io.calamares.core 1.0
import QtQuick

Pagina {
    id: pagina
    simbolo: "regiao"
    titulo: "Idioma e região"
    texto: "O idioma dos menus e o fuso do relógio. Dá para mudar depois em Configurações."
    largura: 820

    Estilo { id: e }
    Nomes { id: nomes }

    readonly property var idiomas: [
        { codigo: "pt_BR.UTF-8", nome: "Português (Brasil)", exemplo: "Olá" },
        { codigo: "pt_PT.UTF-8", nome: "Português (Portugal)", exemplo: "Olá" },
        { codigo: "en_US.UTF-8", nome: "English (United States)", exemplo: "Hello" },
        { codigo: "es_ES.UTF-8", nome: "Español", exemplo: "Hola" }
    ]
    property bool trocandoFuso: false
    property string regiaoEscolhida: config.currentLocation ? config.currentLocation.region : "America"

    // Ao abrir as listas do fuso, a página rola para mostrá-las inteiras
    Timer { id: rolarAteOFim; interval: 260; onTriggered: pagina.rolarParaOFim() }

    Column {
        width: parent.width
        spacing: 18

        // Idioma
        Rectangle {
            width: parent.width
            height: colunaIdioma.implicitHeight + 36
            radius: e.raioGrande
            color: e.cartao
            border.color: e.borda
            Column {
                id: colunaIdioma
                x: 22; y: 18
                width: parent.width - 44
                spacing: 12
                Text { text: "Idioma do sistema"; color: e.texto; font.family: e.fonteTitulo; font.pixelSize: 17; font.weight: Font.Bold }
                Grid {
                    width: parent.width
                    columns: 2
                    columnSpacing: 10; rowSpacing: 10
                    Repeater {
                        model: pagina.idiomas
                        Rectangle {
                            readonly property bool escolhido: config.currentLanguageCode === modelData.codigo
                            width: (colunaIdioma.width - 10) / 2
                            height: 54; radius: 14
                            color: escolhido ? e.selecao : (area.containsMouse ? e.cartaoHover : e.cartao)
                            border.color: escolhido ? e.azul : e.borda
                            border.width: escolhido ? 2 : 1
                            Behavior on color { ColorAnimation { duration: 120 } }
                            Text {
                                anchors.left: parent.left; anchors.leftMargin: 16
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.nome
                                color: e.texto
                                font.family: e.fonteTexto; font.pixelSize: 15
                                font.weight: parent.escolhido ? Font.DemiBold : Font.Normal
                            }
                            Text {
                                anchors.right: parent.right; anchors.rightMargin: 16
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.exemplo
                                color: e.textoApagado
                                font.family: e.fonteTexto; font.pixelSize: 14
                            }
                            MouseArea {
                                id: area
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { config.currentLanguageCode = modelData.codigo; config.currentLCCode = modelData.codigo }
                            }
                        }
                    }
                }
            }
        }

        // Fuso horário
        Rectangle {
            width: parent.width
            height: colunaFuso.implicitHeight + 36
            radius: e.raioGrande
            color: e.cartao
            border.color: e.borda
            Behavior on height { NumberAnimation { duration: e.animacao; easing.type: Easing.OutCubic } }
            clip: true
            Column {
                id: colunaFuso
                x: 22; y: 18
                width: parent.width - 44
                spacing: 14
                Item {
                    width: parent.width; height: 48
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 3
                        Text { text: "Fuso horário"; color: e.texto; font.family: e.fonteTitulo; font.pixelSize: 17; font.weight: Font.Bold }
                        Text {
                            text: config.currentLocation ? nomes.descricao(config.currentLocation.zone) + ", " + nomes.regiao(config.currentLocation.region) : config.currentTimezoneName
                            color: e.textoSecundario; font.family: e.fonteTexto; font.pixelSize: 15
                        }
                    }
                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: rotuloTrocar.width + 32; height: 38; radius: 19
                        color: areaTrocar.containsMouse ? e.selecao : "transparent"
                        border.color: e.borda
                        Text {
                            id: rotuloTrocar
                            anchors.centerIn: parent
                            text: pagina.trocandoFuso ? "Pronto" : "Alterar"
                            color: e.azul; font.family: e.fonteTexto; font.pixelSize: 14; font.weight: Font.DemiBold
                        }
                        MouseArea {
                            id: areaTrocar; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                pagina.trocandoFuso = !pagina.trocandoFuso
                                if (pagina.trocandoFuso) {
                                    config.regionalZonesModel.region = pagina.regiaoEscolhida
                                    rolarAteOFim.start()
                                }
                            }
                        }
                    }
                }

                Row {
                    visible: pagina.trocandoFuso
                    width: parent.width
                    height: 260
                    spacing: 12
                    Lista {
                        width: parent.width * 0.38; height: parent.height
                        modelo: config.regionModel
                        escolhido: pagina.regiaoEscolhida
                        aoEscolher: function(chave) {
                            pagina.regiaoEscolhida = chave
                            config.regionalZonesModel.region = chave
                        }
                    }
                    Lista {
                        width: parent.width * 0.62 - 12; height: parent.height
                        modelo: config.regionalZonesModel
                        escolhido: config.currentLocation ? config.currentLocation.zone : ""
                        mostrarCidade: true
                        aoEscolher: function(chave) { config.setCurrentLocation(pagina.regiaoEscolhida, chave) }
                    }
                }
            }
        }
    }
}
