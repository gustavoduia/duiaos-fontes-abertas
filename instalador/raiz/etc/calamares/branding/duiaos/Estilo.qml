// SPDX-License-Identifier: GPL-3.0-or-later
// DuiaOS — cores, fontes e medidas do instalador (as mesmas do estilo Futurista do sistema).
import QtQuick

QtObject {
    // Páginas de configuração (claras)
    readonly property color fundo: "#F2F4FC"
    readonly property color cartao: "#FFFFFF"
    readonly property color cartaoHover: "#F7F8FE"
    readonly property color texto: "#0E1430"
    readonly property color textoSecundario: "#56608A"
    readonly property color textoApagado: "#8C95B5"
    readonly property color borda: "#DADFF2"
    readonly property color bordaForte: "#BFC8EA"
    readonly property color selecao: "#E7ECFF"
    readonly property color azul: "#3D5BFF"
    readonly property color azulEscuro: "#2F47D9"
    readonly property color sucesso: "#14B88A"
    readonly property color erro: "#E5405E"
    readonly property color aviso: "#C98512"

    // Momentos escuros (boas-vindas, instalação, fim)
    readonly property color noite: "#070B18"
    readonly property color noiteTexto: "#EEF2FF"
    readonly property color noiteSecundario: "#A7B2D6"

    // Degradê aurora (ciano → azul → violeta)
    readonly property color aurora1: "#06B6D4"
    readonly property color aurora2: "#3D5BFF"
    readonly property color aurora3: "#7C3AED"

    readonly property string fonteTitulo: "Manrope"
    readonly property string fonteTexto: "Inter"

    readonly property int raio: 16
    readonly property int raioGrande: 24
    readonly property int animacao: 220
}
