// SPDX-License-Identifier: GPL-3.0-or-later
// DuiaOS — "Sua conta": nome, nome de usuário, nome do computador e senha. O nome de usuário e o do
// computador são sugeridos a partir do nome (dá para trocar).
import io.calamares.ui 1.0
import io.calamares.core 1.0
import QtQuick

Pagina {
    id: pagina
    simbolo: ""
    titulo: "Crie a sua conta"
    texto: "É com ela que você entra no DuiaOS. A senha também autoriza instalar programas e mudar o sistema."
    largura: 640

    Estilo { id: e }
    property string nomeDigitado: config.fullName

    // Foto (iniciais) no alto — muda enquanto a pessoa digita
    topo: Component {
        Rectangle {
            width: 84; height: 84; radius: 42
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: e.aurora1 }
                GradientStop { position: 0.55; color: e.aurora2 }
                GradientStop { position: 1.0; color: e.aurora3 }
            }
            Text {
                anchors.centerIn: parent
                text: pagina.iniciais(pagina.nomeDigitado)
                color: "#FFFFFF"
                font.family: e.fonteTitulo; font.pixelSize: 32; font.weight: Font.ExtraBold
            }
            Image {
                anchors.centerIn: parent
                visible: pagina.iniciais(pagina.nomeDigitado) === ""
                width: 40; height: 40; sourceSize: Qt.size(80, 80)
                source: "simbolos/conta.svg"
            }
        }
    }

    function iniciais(nome) {
        var partes = String(nome || "").trim().split(/\s+/).filter(function(p) { return p.length > 0 })
        if (partes.length === 0) return ""
        var letras = partes[0][0] + (partes.length > 1 ? partes[partes.length - 1][0] : "")
        return letras.toUpperCase()
    }

    Column {
        width: parent.width
        spacing: 18

        Rectangle {
            width: parent.width
            height: campos.implicitHeight + 44
            radius: e.raioGrande
            color: e.cartao
            border.color: e.borda
            Column {
                id: campos
                x: 22; y: 22
                width: parent.width - 44
                spacing: 16

                Campo {
                    id: nome
                    width: parent.width
                    rotulo: "Seu nome"
                    dica: "Ex.: Maria Silva"
                    texto: config.fullName
                    onEditado: function(t) { pagina.nomeDigitado = t; config.setFullName(t) }
                    Component.onCompleted: entrada.forceActiveFocus()
                }
                Row {
                    width: parent.width
                    spacing: 14
                    Campo {
                        width: (parent.width - 14) / 2
                        rotulo: "Nome de usuário"
                        dica: "maria"
                        texto: config.loginName
                        ajuda: "Sem espaços nem acentos"
                        erro: config.loginNameStatus
                        onEditado: function(t) { config.setLoginName(t) }
                    }
                    Campo {
                        width: (parent.width - 14) / 2
                        rotulo: "Nome do computador"
                        dica: "notebook-da-maria"
                        texto: config.hostname
                        ajuda: "Como ele aparece na rede"
                        erro: config.hostnameStatus
                        onEditado: function(t) { config.setHostName(t) }
                    }
                }
                Row {
                    width: parent.width
                    spacing: 14
                    Campo {
                        width: (parent.width - 14) / 2
                        rotulo: "Senha"
                        senha: true
                        texto: config.userPassword
                        onEditado: function(t) { config.setUserPassword(t) }
                    }
                    Campo {
                        width: (parent.width - 14) / 2
                        rotulo: "Confirme a senha"
                        senha: true
                        texto: config.userPasswordSecondary
                        onEditado: function(t) { config.setUserPasswordSecondary(t) }
                    }
                }
                // Situação da senha
                Row {
                    spacing: 8
                    visible: config.userPassword !== "" || config.userPasswordSecondary !== ""
                    Rectangle {
                        width: 8; height: 8; radius: 4
                        anchors.verticalCenter: parent.verticalCenter
                        color: config.userPasswordValidity === 0 ? e.sucesso : (config.userPasswordValidity === 1 ? e.aviso : e.erro)
                    }
                    Text {
                        text: config.userPasswordValidity === 0 ? "As senhas conferem."
                            : (config.userPasswordMessage || "Confira a senha.")
                        color: config.userPasswordValidity === 2 ? e.erro : e.textoSecundario
                        font.family: e.fonteTexto; font.pixelSize: 13
                    }
                }
            }
        }
    }
}
