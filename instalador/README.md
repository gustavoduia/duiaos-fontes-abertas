# Instalador do DuiaOS

O instalador do DuiaOS é o [Calamares](https://calamares.io) (GPL-3) com a identidade do DuiaOS.
Tudo o que está em `raiz/` é copiado para a ISO por cima dos pacotes `calamares` e
`calamares-settings-debian` do Debian 13 (de onde vêm a sequência de instalação e os passos próprios
do Debian: `sources-media`, `bootloader-config` e os outros).

| Caminho | O que é |
| --- | --- |
| `raiz/etc/calamares/settings.conf` | A sequência: boas-vindas, idioma e região, teclado, disco, conta, programas, aparência, revisar; a cópia; pronto |
| `raiz/etc/calamares/branding/duiaos/*.qml` | Uma página por assunto (`welcomeq`, `localeq`, `keyboardq`, `usersq`, `programas`, `aparencia`, `summaryq`, `show`, `finishedq`), as faixas do alto e de baixo (`calamares-sidebar.qml`, `calamares-navigation.qml`) e as peças comuns (`Pagina`, `Cartaz`, `Campo`, `Lista`, `Linha`, `Amostra`, `Estilo`, `Nomes`) |
| `raiz/etc/calamares/branding/duiaos/stylesheet.qss` | O estilo da única página em widgets (o disco), das perguntas e da barra de andamento |
| `raiz/etc/calamares/modules/` | A configuração de cada página (`partition.conf`, `usersq.conf`, `aparencia.conf`…) |
| `raiz/usr/share/duiaos/instalador/modulos/duiaos/` | Último passo (módulo Python do Calamares, GPL-3): grava o modo escolhido, ajusta repositórios e chama a instalação dos programas |
| `raiz/usr/lib/duiaos/instalar-programas` | Instala os programas escolhidos; o que faltar chega quando o sistema ligar com internet (`duiaos-programas.service`) |
| `raiz/usr/lib/duiaos/instalar` | Abre o instalador no modo live |

Licença: GPL-3.0-or-later (os arquivos que se ligam ao Calamares). As imagens e a marca seguem `TRADEMARKS.md`.

Os ícones em `branding/duiaos/programas/` mostram os programas que a pessoa pode escolher e são marcas dos seus
donos: Firefox e Thunderbird (Mozilla, dos pacotes do Debian), Google Chrome (Google, do pacote oficial), LibreOffice
(The Document Foundation, do pacote do Debian), VLC (VideoLAN, do pacote do Debian) e Telegram (Telegram FZ-LLC, do
repositório do Telegram Desktop). Os ícones do WhatsApp e do antivírus foram desenhados pelo DuiaOS (genéricos).

Para testar as páginas sem instalar: um Debian 13 com `calamares` e `calamares-settings-debian`, esta pasta copiada
por cima de `/etc/calamares` e `calamares -d` numa tela (Xvfb serve). Troque antes os passos de `exec:` por
`dummypython`, para que nada seja gravado no disco.
O papel de parede `paisagem.jpg` foi fornecido pelo dono do projeto.
