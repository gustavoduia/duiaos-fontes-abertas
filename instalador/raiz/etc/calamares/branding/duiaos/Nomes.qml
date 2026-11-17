// SPDX-License-Identifier: GPL-3.0-or-later
// DuiaOS — nomes em português para as regiões e cidades do fuso horário (o banco de fusos usa os
// nomes em inglês e sem acento).
import QtQuick

QtObject {
    readonly property var regioes: ({
        "Africa": "África", "America": "Américas", "Antarctica": "Antártida", "Arctic": "Ártico",
        "Asia": "Ásia", "Atlantic": "Oceano Atlântico", "Australia": "Austrália", "Europe": "Europa",
        "Indian": "Oceano Índico", "Pacific": "Oceano Pacífico"
    })
    readonly property var cidades: ({
        "Sao_Paulo": "São Paulo", "Belem": "Belém", "Maceio": "Maceió", "Cuiaba": "Cuiabá",
        "Araguaina": "Araguaína", "Santarem": "Santarém", "Porto_Velho": "Porto Velho", "Rio_Branco": "Rio Branco",
        "Boa_Vista": "Boa Vista", "Campo_Grande": "Campo Grande", "Noronha": "Fernando de Noronha",
        "Eirunepe": "Eirunepé", "Bahia": "Salvador", "Recife": "Recife", "Fortaleza": "Fortaleza",
        "Manaus": "Manaus", "Lisbon": "Lisboa", "New_York": "Nova York", "Los_Angeles": "Los Angeles",
        "Mexico_City": "Cidade do México", "Buenos_Aires": "Buenos Aires", "Santiago": "Santiago",
        "Bogota": "Bogotá", "Lima": "Lima", "Asuncion": "Assunção", "Montevideo": "Montevidéu",
        "Madrid": "Madri", "London": "Londres", "Paris": "Paris", "Berlin": "Berlim", "Rome": "Roma",
        "Tokyo": "Tóquio", "Luanda": "Luanda", "Maputo": "Maputo"
    })
    readonly property var brasilia: ["Sao_Paulo", "Bahia", "Fortaleza", "Recife", "Belem", "Maceio", "Araguaina", "Santarem"]

    function regiao(chave) { return regioes[chave] || String(chave || "").replace(/_/g, " ") }
    function cidade(chave) {
        var partes = String(chave || "").split("/")
        var ultima = partes[partes.length - 1]
        return cidades[ultima] || ultima.replace(/_/g, " ")
    }
    function descricao(zona) {
        return brasilia.indexOf(zona) >= 0 ? "Horário de Brasília (" + cidade(zona) + ")" : cidade(zona)
    }

    // Nomes dos layouts de teclado (o xkb só tem em inglês)
    readonly property var teclas: [
        ["Portuguese", "Português"], ["(Brazil", "(Brasil"], ["English", "Inglês"], ["Spanish", "Espanhol"],
        ["German", "Alemão"], ["French", "Francês"], ["Italian", "Italiano"], ["Japanese", "Japonês"],
        ["Russian", "Russo"], ["Greek", "Grego"], ["Hebrew", "Hebraico"], ["Hungarian", "Húngaro"],
        ["Icelandic", "Islandês"], ["Dutch", "Holandês"], ["Polish", "Polonês"], ["Swedish", "Sueco"],
        ["Norwegian", "Norueguês"], ["Danish", "Dinamarquês"], ["Finnish", "Finlandês"], ["Turkish", "Turco"],
        ["Chinese", "Chinês"], ["Korean", "Coreano"], ["Arabic", "Árabe"], ["Ukrainian", "Ucraniano"],
        ["Czech", "Tcheco"], ["Romanian", "Romeno"], ["Belgian", "Belga"], ["Canadian", "Canadense"],
        ["(Austria", "(Áustria"], ["(Switzerland", "(Suíça"], ["(Latin American", "(América Latina"],
        ["(US", "(EUA"], ["(UK", "(Reino Unido"], ["(Spain", "(Espanha"], ["(France", "(França"],
        ["(Germany", "(Alemanha"], ["(Canada", "(Canadá"], ["no dead keys", "sem teclas mortas"],
        ["with dead keys", "com teclas mortas"], ["Nativo for US keyboards", "Nativo para teclados americanos"],
        ["intl.", "internacional"], ["international", "internacional"], ["Macintosh", "Mac"]
    ]
    function teclado(nome) {
        var texto = String(nome || "")
        for (var i = 0; i < teclas.length; ++i) texto = texto.split(teclas[i][0]).join(teclas[i][1])
        return texto
    }
    // "Portuguese (Brazil, Dvorak)" dentro de "Portuguese (Brazil)" → "Dvorak"
    function variante(nome, layout) {
        var texto = String(nome || ""), base = String(layout || "")
        var prefixo = base.replace(/\)$/, "") + ", "
        if (base && texto.indexOf(prefixo) === 0) return teclado(texto.slice(prefixo.length).replace(/\)$/, ""))
        return teclado(texto)
    }
}
