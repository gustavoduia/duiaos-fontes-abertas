// SPDX-License-Identifier: GPL-3.0-or-later
// DuiaOS — "Revisar": o que vai acontecer, numa lista só, antes de começar a instalar. As escolhas são
// lidas do armazenamento global do instalador a cada troca de etapa; o que vai mudar no disco vem
// do resumo do próprio particionamento.
import io.calamares.ui 1.0
import io.calamares.core 1.0
import QtQuick

Pagina {
    id: pagina
    simbolo: "revisar"
    titulo: "Tudo pronto para instalar"
    texto: "Confira as escolhas. Ao clicar em Instalar agora, o disco começa a ser preparado, e isso não dá para desfazer."
    largura: 760

    Estilo { id: e }
    Nomes { id: nomes }

    // Relê as escolhas a cada troca de etapa: o SummaryQmlViewStep do Calamares 3.3 não chama o onActivate()
    // do QML, e o armazenamento global não avisa quando muda (sem isso, a página mostrava o que havia ao
    // carregar: teclado "Padrão", sem fuso e sem conta).
    readonly property int versao: ViewManager.currentStepIndex

    readonly property var nomesProgramas: ({ libreoffice: "LibreOffice", vlc: "VLC", whatsapp: "WhatsApp", telegram: "Telegram", antivirus: "Antivírus" })
    readonly property var nomesModos: ({ claro: "claro", escuro: "escuro", automatico: "automático (claro de dia, escuro à noite)" })
    readonly property var nomesIdiomas: ({ "pt_BR": "Português (Brasil)", "pt_PT": "Português (Portugal)", "en_US": "English (United States)", "es_ES": "Español" })
    readonly property var nomesTeclados: ({ br: "Português (Brasil)", pt: "Português (Portugal)", us: "Inglês (EUA)", es: "Espanhol", latam: "Espanhol (América Latina)", gb: "Inglês (Reino Unido)" })

    function valor(chave) { var _ = versao; return Global.value(chave) }

    function programas() {
        var lista = String(valor("packagechooser_packagechooserq") || "").split(",").filter(function(p) { return p.length > 0 })
        return lista.length ? lista.map(function(p) { return nomesProgramas[p] || p }).join(", ") : "Nenhum programa a mais"
    }
    function aparencia() {
        var modo = String(valor("packagechooser_aparencia") || "claro")
        return "Estilo Futurista, modo " + (nomesModos[modo] || modo)
    }
    function idiomaERegiao() {
        var locale = valor("localeConf") || {}
        var lang = String(locale.LANG || "pt_BR.UTF-8").split(".")[0]
        var zona = String(valor("locationZone") || "")
        return (nomesIdiomas[lang] || lang) + (zona ? "\nFuso: " + nomes.descricao(zona) : "")
    }
    function teclado() {
        var layout = String(valor("keyboardLayout") || "")
        var variante = String(valor("keyboardVariant") || "")
        return (nomesTeclados[layout] || layout || "Padrão") + (variante ? ", variante " + variante : "")
    }
    function conta() {
        var nome = String(valor("fullname") || ""), usuario = String(valor("username") || ""), computador = String(valor("hostname") || "")
        return (nome ? nome + " (" + usuario + ")" : usuario) + (computador ? "\nComputador: " + computador : "")
    }
    function ehDisco(titulo) {
        var t = String(titulo || "").toLowerCase()
        return t.indexOf("parti") >= 0 || t.indexOf("disco") >= 0 || t.indexOf("disk") >= 0
    }

    Column {
        width: parent.width
        spacing: 12

        // O que muda no disco vem primeiro: é o que não dá para desfazer
        Repeater {
            model: config.summaryModel
            Linha {
                visible: pagina.ehDisco(model.title)
                height: visible ? implicitHeight : 0
                rotulo: "Disco"
                simbolo: "disco"
                valor: model.message
                rico: true
                destaque: true
            }
        }
        Linha { rotulo: "Idioma e região"; valor: pagina.idiomaERegiao(); simbolo: "regiao" }
        Linha { rotulo: "Teclado"; valor: pagina.teclado(); simbolo: "teclado" }
        Linha { rotulo: "Sua conta"; valor: pagina.conta(); simbolo: "conta" }
        Linha { rotulo: "Programas"; valor: pagina.programas(); simbolo: "programas" }
        Linha { rotulo: "Aparência"; valor: pagina.aparencia(); simbolo: "aparencia" }
    }
}
