// SPDX-License-Identifier: GPL-3.0-or-later
// DuiaOS — miniatura da área de trabalho em cada modo (papel de parede, barra do alto, uma janela e a Ilha).
import QtQuick
import QtQuick.Effects

Item {
    id: amostra
    property string modo: "claro"             // claro, escuro ou automatico
    Estilo { id: e }

    function cores(escuro) {
        return escuro ? { barra: "#CC0A0F1F", janela: "#131A30", linha: "#232C4D", texto: "#C7D6FF", ilha: "#99141B33" }
                      : { barra: "#D9F4F6FF", janela: "#FFFFFF", linha: "#DADFF2", texto: "#16205C", ilha: "#B3FFFFFF" }
    }

    Item {
        id: tela
        anchors.fill: parent
        visible: false
        layer.enabled: true

        Image { anchors.fill: parent; source: "paisagem.jpg"; fillMode: Image.PreserveAspectCrop; sourceSize.width: 480 }
        // Metade de cada (automático): a metade direita em modo escuro
        Repeater {
            model: amostra.modo === "automatico" ? [false, true] : [amostra.modo === "escuro"]
            Item {
                readonly property var c: amostra.cores(modelData)
                readonly property bool metade: amostra.modo === "automatico"
                x: metade && modelData ? tela.width / 2 : 0
                width: metade ? tela.width / 2 : tela.width
                height: tela.height
                clip: true
                Rectangle { anchors.fill: parent; color: modelData ? "#55070B18" : "transparent" }
                Rectangle { x: -parent.x; width: tela.width; height: tela.height * 0.07; color: c.barra }
                Rectangle {
                    x: tela.width * 0.18 - parent.x; y: tela.height * 0.2
                    width: tela.width * 0.64; height: tela.height * 0.52; radius: 6
                    color: c.janela
                    Row { anchors.right: parent.right; anchors.rightMargin: 8; y: 7; spacing: 4
                        Repeater { model: ["#FF5F57", "#FEBC2E", "#28C840"]; Rectangle { width: 6; height: 6; radius: 3; color: modelData } }
                    }
                    Rectangle { x: 10; y: 22; width: parent.width * 0.45; height: 6; radius: 3; color: c.texto; opacity: 0.85 }
                    Rectangle { x: 10; y: 34; width: parent.width * 0.7; height: 5; radius: 2.5; color: c.linha }
                    Rectangle { x: 10; y: 44; width: parent.width * 0.6; height: 5; radius: 2.5; color: c.linha }
                    Rectangle {
                        x: 10; y: parent.height - 20; width: 52; height: 12; radius: 6
                        gradient: Gradient { orientation: Gradient.Horizontal
                            GradientStop { position: 0; color: e.aurora1 } GradientStop { position: 0.55; color: e.aurora2 } GradientStop { position: 1; color: e.aurora3 } }
                    }
                }
                Rectangle {
                    x: tela.width * 0.3 - parent.x; y: tela.height * 0.82
                    width: tela.width * 0.4; height: tela.height * 0.12; radius: height / 2.6
                    color: c.ilha
                }
            }
        }
    }
    Item { id: mascara; anchors.fill: tela; visible: false; layer.enabled: true
        Rectangle { anchors.fill: parent; radius: 12; color: "black" } }
    MultiEffect { anchors.fill: tela; source: tela; maskEnabled: true; maskSource: mascara }
}
