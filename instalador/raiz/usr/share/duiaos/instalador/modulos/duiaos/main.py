#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
# DuiaOS — último passo do instalador (módulo do Calamares): aplica no sistema novo o que a pessoa
# escolheu nas páginas "Programas" e "Aparência" e os ajustes do DuiaOS.
# Copyright (C) 2026 DuiaOS. Software livre: GNU GPL, versão 3 ou posterior.
import os
import shutil
import subprocess

import libcalamares


def pretty_name():
    return "Ajustando o DuiaOS e instalando os seus programas"


def ler_escolha(texto):
    """"firefox,vlc;modo=escuro" → (["firefox", "vlc"], {"modo": "escuro"}). Só nomes conhecidos passam adiante
    (o programa que instala confere de novo)."""
    programas, opcoes = [], {}
    for parte in str(texto or "").replace(";", ",").split(","):
        parte = parte.strip().lower()
        if "=" in parte:
            chave, _, valor = parte.partition("=")
            if chave in ("modo",) and valor in ("claro", "escuro", "automatico"):
                opcoes[chave] = valor
        elif parte.replace("-", "").isalnum() and len(parte) <= 30:
            programas.append(parte)
    return programas, opcoes


def gravar_aparencia(raiz, usuario, modo):
    """Modo claro, escuro ou automático para a conta criada (e para as próximas: /etc/skel)."""
    texto = ("# DuiaOS — preferências (escolhidas na instalação)\n[aparencia]\n"
             f"modo = {'escuro' if modo == 'escuro' else 'claro'}\nautomatico = {'sim' if modo == 'automatico' else 'nao'}\n"
             "estilo = futurista\n")
    destinos = [os.path.join(raiz, "etc/skel/.config/duiaos")]
    if usuario and os.path.isdir(os.path.join(raiz, "home", usuario)):
        destinos.append(os.path.join(raiz, "home", usuario, ".config/duiaos"))
    for pasta in destinos:
        os.makedirs(pasta, exist_ok=True)
        with open(os.path.join(pasta, "preferencias.conf"), "w", encoding="utf-8") as saida:
            saida.write(texto)
    if usuario and len(destinos) > 1:
        libcalamares.utils.target_env_call(["chown", "-R", f"{usuario}:", f"/home/{usuario}/.config"])


def run():
    gs = libcalamares.globalstorage
    raiz = gs.value("rootMountPoint")
    if not raiz or not os.path.isdir(raiz):
        return ("O DuiaOS não terminou de ser ajustado", "O instalador não encontrou o sistema novo.")
    programas, opcoes = ler_escolha(gs.value("packagechooser_packagechooserq"))
    modo = str(gs.value("packagechooser_aparencia") or opcoes.get("modo", "claro")).strip().lower()
    if modo not in ("claro", "escuro", "automatico"):
        modo = "claro"
    usuario = gs.value("username") or ""

    libcalamares.job.setprogress(0.05)
    gravar_aparencia(raiz, usuario, modo)

    # Repositórios do Debian e do DuiaOS, SSH desligado, chaves deste computador (o mesmo do instalador clássico)
    if os.path.exists(os.path.join(raiz, "usr/lib/duiaos/pos-instalacao")):
        libcalamares.utils.target_env_call(["env", "DUIAOS_INSTALADOR=calamares", "/usr/lib/duiaos/pos-instalacao"])
    # O instalador não fica no sistema instalado
    for sobra in ("usr/share/applications/duiaos-instalar.desktop", "etc/xdg/autostart/calamares-desktop-icon.desktop",
                  "usr/share/applications/calamares-install-debian.desktop"):
        try:
            os.remove(os.path.join(raiz, sobra))
        except OSError:
            pass
    libcalamares.job.setprogress(0.15)

    # Programas: a lista fica gravada; tenta agora (com internet) e o que faltar chega na primeira vez que o
    # sistema ligar com internet (duiaos-programas.service)
    if programas:
        os.makedirs(os.path.join(raiz, "var/lib/duiaos"), exist_ok=True)
        with open(os.path.join(raiz, "var/lib/duiaos/programas-pendentes"), "w", encoding="utf-8") as saida:
            saida.write("\n".join(programas) + "\n")
        libcalamares.utils.target_env_call(["systemctl", "enable", "duiaos-programas.service"])
        resolv = os.path.join(raiz, "etc/resolv.conf")
        copiado = False
        try:
            if not os.path.exists(resolv) or os.path.islink(resolv) and not os.path.exists(os.path.realpath(resolv)):
                if os.path.islink(resolv):
                    os.rename(resolv, resolv + ".duiaos")
                shutil.copyfile("/etc/resolv.conf", resolv)
                copiado = True
        except OSError:
            pass
        try:
            # Até 40 minutos; sem internet ele sai na hora e deixa tudo para a primeira inicialização
            processo = subprocess.Popen(["chroot", raiz, "/usr/lib/duiaos/instalar-programas", "--agora"],
                                        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
            feitos = 0
            for linha in processo.stdout:
                libcalamares.utils.debug("duiaos-programas: " + linha.rstrip())
                if linha.startswith("OK ") or linha.startswith("FALHOU "):
                    feitos += 1
                    libcalamares.job.setprogress(0.15 + 0.8 * feitos / max(1, len(programas)))
            processo.wait(timeout=2400)
        except (OSError, subprocess.SubprocessError) as erro:
            libcalamares.utils.warning(f"duiaos-programas: {erro}")
        finally:
            if copiado:
                try:
                    os.remove(resolv)
                    if os.path.lexists(resolv + ".duiaos"):
                        os.rename(resolv + ".duiaos", resolv)
                except OSError:
                    pass
    libcalamares.job.setprogress(1.0)
    return None
