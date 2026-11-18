// SPDX-License-Identifier: GPL-3.0-or-later
// DuiaOS — "Programas": o que já vem instalado junto com o DuiaOS. A escolha vai para o passo "duiaos"
// como texto (ex.: "libreoffice,vlc"), que só aceita os nomes desta lista. O navegador (Ora) e o e-mail
// (Mail Box) do DuiaOS já vêm instalados com o sistema: não são escolhas desta página (ADR 073).
import io.calamares.ui 1.0
import io.calamares.core 1.0
import QtQuick

Pagina {
    id: pagina
    simbolo: "programas"
    titulo: "Programas para começar"
    texto: "O Ora (navegador) e o Mail Box (e-mail) já vêm com o DuiaOS. Marque o que mais você quer usar: com internet, chega junto com o sistema; sem internet, na primeira vez que o computador se conectar."
    largura: 860

    Estilo { id: e }

    readonly property var programas: [
        { id: "thunderbird", nome: "Thunderbird", texto: "E-mail e agenda", icone: "programas/thunderbird.png" },
        { id: "libreoffice", nome: "LibreOffice", texto: "Textos, planilhas e apresentações", icone: "programas/libreoffice.png" },
        { id: "vlc", nome: "VLC", texto: "Vídeos e músicas de qualquer formato", icone: "programas/vlc.png" },
        { id: "whatsapp", nome: "WhatsApp", texto: "O WhatsApp Web numa janela própria", icone: "programas/whatsapp.svg" },
        { id: "telegram", nome: "Telegram", texto: "Mensagens (pelo Flathub)", icone: "programas/telegram.png" },
        { id: "antivirus", nome: "Antivírus", texto: "ClamAV, livre e gratuito", icone: "programas/antivirus.svg" }
    ]
    property var marcados: String(config.packageChoice || "").split(",").filter(function(p) { return p.length > 0 })

    function alternar(id) {
        var lista = marcados.slice()
        var i = lista.indexOf(id)
        if (i >= 0) lista.splice(i, 1); else lista.push(id)
        marcados = lista
        config.packageChoice = lista.join(",")
    }

    Column {
        width: parent.width
        spacing: 14

        Grid {
            id: grade
            width: parent.width
            columns: 2
            columnSpacing: 12; rowSpacing: 10
            Repeater {
                model: pagina.programas
                Rectangle {
                    readonly property bool marcado: pagina.marcados.indexOf(modelData.id) >= 0
                    width: (grade.width - 12) / 2
                    height: 70
                    radius: 18
                    color: marcado ? e.selecao : (area.containsMouse ? e.cartaoHover : e.cartao)
                    border.color: marcado ? e.azul : e.borda
                    border.width: marcado ? 2 : 1
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Image {
                        id: icone
                        anchors.left: parent.left; anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        width: 44; height: 44
                        sourceSize: Qt.size(88, 88)
                        source: modelData.icone
                        smooth: true; mipmap: true
                    }
                    Column {
                        anchors.left: icone.right; anchors.leftMargin: 14
                        anchors.right: marca.left; anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 3
                        Text { text: modelData.nome; color: e.texto; font.family: e.fonteTexto; font.pixelSize: 16; font.weight: Font.DemiBold }
                        Text { width: parent.width; text: modelData.texto; color: e.textoSecundario; font.family: e.fonteTexto; font.pixelSize: 13; elide: Text.ElideRight }
                    }
                    Rectangle {
                        id: marca
                        anchors.right: parent.right; anchors.rightMargin: 18
                        anchors.verticalCenter: parent.verticalCenter
                        width: 24; height: 24; radius: 12
                        color: parent.marcado ? e.azul : "transparent"
                        border.color: parent.marcado ? e.azul : e.bordaForte
                        border.width: 2
                        Image { anchors.centerIn: parent; width: 16; height: 16; sourceSize: Qt.size(32, 32); source: "simbolos/marcado.svg"; visible: parent.parent.marcado }
                    }
                    MouseArea { id: area; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: pagina.alternar(modelData.id) }
                }
            }
        }

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: "Depois, a Duia App Store tem milhares de outros programas."
            color: e.textoSecundario
            font.family: e.fonteTexto; font.pixelSize: 14
        }
    }
}
