# Instalador do DuiaOS

O instalador do DuiaOS é o [Calamares](https://calamares.io) (GPL-3) com a identidade do DuiaOS.
Tudo o que está em `raiz/` é copiado para a ISO por cima dos pacotes `calamares` e
`calamares-settings-debian` do Debian 13 (de onde vêm a sequência de instalação e os passos próprios
do Debian: `sources-media`, `bootloader-config` e os outros).

| Caminho | O que é |
| --- | --- |
| `raiz/etc/calamares/settings.conf` | A sequência: boas-vindas, idioma, teclado, disco, conta, **Programas e aparência**, resumo |
| `raiz/etc/calamares/branding/duiaos/` | Identidade: cores, estilo (`stylesheet.qss`), imagens, a apresentação durante a cópia (`show.qml`) e a página **Programas e aparência** (`packagechooserq.qml`) |
| `raiz/usr/share/duiaos/instalador/modulos/duiaos/` | Último passo (módulo Python do Calamares, GPL-3): grava o modo escolhido, ajusta repositórios e chama a instalação dos programas |
| `raiz/usr/lib/duiaos/instalar-programas` | Instala os programas escolhidos; o que faltar chega quando o sistema ligar com internet (`duiaos-programas.service`) |
| `raiz/usr/lib/duiaos/instalar` | Abre o instalador no modo live |

Licença: GPL-3.0-or-later (os arquivos que se ligam ao Calamares). As imagens e a marca seguem `TRADEMARKS.md`.
O papel de parede `paisagem.jpg` foi fornecido pelo dono do projeto.
