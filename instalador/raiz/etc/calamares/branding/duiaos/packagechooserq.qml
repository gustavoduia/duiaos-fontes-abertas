// SPDX-License-Identifier: GPL-3.0-or-later
// DuiaOS — página "Programas e aparência" do instalador.
// A pessoa escolhe os programas que chegam junto com o sistema e o modo (claro, escuro ou automático).
// A escolha vira um texto ("firefox,vlc;modo=escuro") em config.packageChoice; o passo "duiaos" aplica.
import io.calamares.core 1.0
import io.calamares.ui 1.0
import QtQuick 2.15
import QtQml 2.15

Item {
    id: pagina
    width: parent ? parent.width : 760
    height: parent ? parent.height : 520

    readonly property var programas: [
        { id: "firefox", nome: "Firefox", texto: "Navegador da Mozilla", cor: "#F97316", letra: "F" },
        { id: "chrome", nome: "Google Chrome", texto: "Navegador do Google (baixado do Google)", cor: "#22A565", letra: "C" },
        { id: "thunderbird", nome: "Thunderbird", texto: "E-mail e agenda", cor: "#3D5BFF", letra: "T" },
        { id: "libreoffice", nome: "LibreOffice", texto: "Textos, planilhas e apresentações", cor: "#16A34A", letra: "L" },
        { id: "vlc", nome: "VLC", texto: "Vídeos e músicas de qualquer formato", cor: "#F59E0B", letra: "V" },
        { id: "whatsapp", nome: "WhatsApp Web", texto: "O WhatsApp numa janela própria", cor: "#10B981", letra: "W" },
        { id: "telegram", nome: "Telegram", texto: "Mensagens", cor: "#0EA5E9", letra: "T" },
        { id: "antivirus", nome: "Antivírus ClamAV", texto: "Livre e gratuito, com a tela ClamTk", cor: "#EF4444", letra: "A" }
    ]
    property var marcados: ({ firefox: true, libreoffice: true, vlc: true })
    property string modo: "claro"

    function atualizar() {
        var lista = []
        for (var i = 0; i < programas.length; i++) if (marcados[programas[i].id]) lista.push(programas[i].id)
        config.packageChoice = lista.join(",") + ";modo=" + modo
    }
    function alternar(id) { var m = Object.assign({}, marcados); if (m[id]) delete m[id]; else m[id] = true; marcados = m; atualizar() }
    // (sem Component.onCompleted: o Calamares registra um tipo chamado Component)
    Timer { interval: 0; running: true; onTriggered: pagina.atualizar() }

    Flickable {
        anchors.fill: parent
        contentHeight: coluna.height + 24
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: coluna
            x: 8; y: 8
            width: parent.width - 16
            spacing: 14

            Text { text: "Programas para começar"; color: "#16205C"; font { family: "Manrope"; pixelSize: 22; weight: Font.ExtraBold } }
            Text { width: parent.width; wrapMode: Text.WordWrap; color: "#56608A"; font { family: "Inter"; pixelSize: 13 }
                   text: "Marque o que você quer. Com internet, eles são baixados e instalados junto com o DuiaOS; sem internet, chegam na primeira vez que o computador ligar conectado. Depois, a Duia App Store tem milhares de outros." }

            Grid {
                id: grade
                width: parent.width
                columns: width > 620 ? 2 : 1
                spacing: 10
                Repeater {
                    model: pagina.programas
                    Rectangle {
                        id: cartao
                        readonly property bool marcado: pagina.marcados[modelData.id] === true
                        width: (grade.width - (grade.columns - 1) * grade.spacing) / grade.columns
                        height: 64; radius: 16
                        color: marcado ? "#E2E8FF" : (area.containsMouse ? "#F6F8FF" : "#FFFFFF")
                        border { color: marcado ? "#3D5BFF" : "#DADFF2"; width: marcado ? 2 : 1 }
                        Rectangle {
                            id: icone
                            x: 12; anchors.verticalCenter: parent.verticalCenter
                            width: 40; height: 40; radius: 12
                            gradient: Gradient { GradientStop { position: 0; color: Qt.lighter(modelData.cor, 1.25) } GradientStop { position: 1; color: modelData.cor } }
                            Text { anchors.centerIn: parent; text: modelData.letra; color: "white"; font { family: "Manrope"; pixelSize: 20; weight: Font.ExtraBold } }
                        }
                        Column {
                            anchors { left: icone.right; leftMargin: 12; right: caixa.left; rightMargin: 8; verticalCenter: parent.verticalCenter }
                            Text { width: parent.width; text: modelData.nome; elide: Text.ElideRight; color: "#0E1430"; font { family: "Inter"; pixelSize: 14; weight: Font.DemiBold } }
                            Text { width: parent.width; text: modelData.texto; elide: Text.ElideRight; color: "#56608A"; font { family: "Inter"; pixelSize: 12 } }
                        }
                        Rectangle {
                            id: caixa
                            anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
                            width: 22; height: 22; radius: 7
                            color: cartao.marcado ? "#3D5BFF" : "transparent"
                            border { color: cartao.marcado ? "#3D5BFF" : "#BFC8EA"; width: 1.5 }
                            Text { anchors.centerIn: parent; visible: cartao.marcado; text: "✓"; color: "white"; font { pixelSize: 14; weight: Font.Bold } }
                        }
                        MouseArea { id: area; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: pagina.alternar(modelData.id) }
                    }
                }
            }

            Item { width: 1; height: 4 }
            Text { text: "Aparência"; color: "#16205C"; font { family: "Manrope"; pixelSize: 22; weight: Font.ExtraBold } }
            Text { width: parent.width; wrapMode: Text.WordWrap; color: "#56608A"; font { family: "Inter"; pixelSize: 13 }
                   text: "O DuiaOS vem com o estilo Futurista. Escolha o modo; dá para mudar depois em Configurações › Aparência." }
            Row {
                spacing: 10
                Repeater {
                    model: [ { id: "claro", nome: "Claro", texto: "Fundo claro o dia todo", fundo: "#F2F4FC", traco: "#0E1430" },
                             { id: "escuro", nome: "Escuro", texto: "Fundo azul-noite", fundo: "#0A0F1F", traco: "#EEF2FF" },
                             { id: "automatico", nome: "Automático", texto: "Claro de dia, escuro à noite", fundo: "", traco: "#0E1430" } ]
                    Rectangle {
                        readonly property bool marcado: pagina.modo === modelData.id
                        width: Math.min(220, (coluna.width - 20) / 3); height: 132; radius: 16
                        color: marcado ? "#E2E8FF" : "#FFFFFF"
                        border { color: marcado ? "#3D5BFF" : "#DADFF2"; width: marcado ? 2 : 1 }
                        // Miniatura de uma janela no modo
                        Rectangle {
                            id: mini
                            x: 12; y: 12; width: parent.width - 24; height: 64; radius: 10; clip: true
                            color: modelData.fundo !== "" ? modelData.fundo : "#F2F4FC"
                            border { color: "#DADFF2"; width: 1 }
                            Rectangle { visible: modelData.id === "automatico"; x: parent.width / 2; width: parent.width / 2; height: parent.height; color: "#0A0F1F" }
                            Rectangle { x: 10; y: 12; width: parent.width * 0.5; height: 7; radius: 3.5; color: modelData.traco; opacity: 0.85 }
                            Rectangle { x: 10; y: 26; width: parent.width * 0.3; height: 5; radius: 2.5; color: modelData.traco; opacity: 0.4 }
                            Rectangle { x: 10; y: 42; width: 46; height: 14; radius: 7
                                        gradient: Gradient { orientation: Gradient.Horizontal
                                                             GradientStop { position: 0; color: "#06B6D4" } GradientStop { position: 0.5; color: "#3D5BFF" } GradientStop { position: 1; color: "#7C3AED" } } }
                        }
                        Text { x: 14; y: 84; text: modelData.nome; color: "#0E1430"; font { family: "Inter"; pixelSize: 14; weight: Font.DemiBold } }
                        Text { x: 14; y: 104; width: parent.width - 28; elide: Text.ElideRight; text: modelData.texto; color: "#56608A"; font { family: "Inter"; pixelSize: 12 } }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { pagina.modo = modelData.id; pagina.atualizar() } }
                    }
                }
            }
        }
    }
}
