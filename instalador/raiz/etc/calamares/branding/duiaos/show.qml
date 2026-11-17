// DuiaOS — o que aparece enquanto o sistema é instalado: a paisagem do DuiaOS e, por cima,
// uma frase por vez sobre o que vem no sistema.
import QtQuick 2.15

Item {
    id: tela
    anchors.fill: parent
    property int atual: 0
    readonly property var frases: [
        { titulo: "Bem-vindo ao DuiaOS", texto: "Você diz o que quer. O DuiaOS descobre como fazer." },
        { titulo: "O Wise já vem com o sistema", texto: "Peça em português: instalar um aplicativo, achar um arquivo, ver a agenda ou a previsão do tempo. Ele pede a sua aprovação antes de mudar qualquer coisa." },
        { titulo: "A IA roda no seu computador", texto: "O modelo de IA local é baixado na primeira entrada. Nada sai do computador, a não ser que você ligue um motor na nuvem." },
        { titulo: "Do seu jeito", texto: "Modo claro, escuro ou automático, a Ilha de Aplicativos onde você preferir e os menus dos aplicativos na barra do alto." },
        { titulo: "Sempre em dia", texto: "O DuiaOS procura atualizações sozinho e mostra, em português, o que cada uma muda." },
        { titulo: "Quase lá", texto: "Quando terminar, tire o pendrive e reinicie. Seus programas escolhidos chegam junto, se houver internet." }
    ]
    function onActivate() { troca.restart() }
    function onLeave() { troca.stop() }

    Image { anchors.fill: parent; source: "paisagem.jpg"; fillMode: Image.PreserveAspectCrop; asynchronous: true }
    Rectangle { anchors.fill: parent
                gradient: Gradient { GradientStop { position: 0.35; color: "#000A0F1F" } GradientStop { position: 1; color: "#E60A0F1F" } } }
    Image { source: "logo.png"; width: 56; height: 56; x: 36; y: 30; smooth: true }

    Column {
        id: caixa
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 40; bottomMargin: 46 }
        spacing: 10
        Text { width: parent.width; text: tela.frases[tela.atual].titulo; color: "white"; wrapMode: Text.WordWrap
               font { family: "Manrope"; pixelSize: 30; weight: Font.ExtraBold } }
        Text { width: Math.min(parent.width, 640); text: tela.frases[tela.atual].texto; color: "#DCE6FF"; wrapMode: Text.WordWrap
               font { family: "Inter"; pixelSize: 16 } lineHeight: 1.25 }
        Row {
            spacing: 6; topPadding: 10
            Repeater { model: tela.frases.length
                Rectangle { required property int index; width: index === tela.atual ? 22 : 8; height: 8; radius: 4
                            color: index === tela.atual ? "white" : "#66FFFFFF"
                            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } } } }
        }
    }
    SequentialAnimation {
        id: passagem
        NumberAnimation { target: caixa; property: "opacity"; to: 0; duration: 260 }
        ScriptAction { script: tela.atual = (tela.atual + 1) % tela.frases.length }
        NumberAnimation { target: caixa; property: "opacity"; to: 1; duration: 420 }
    }
    Timer { id: troca; interval: 9000; repeat: true; running: true; onTriggered: passagem.restart() }
}
