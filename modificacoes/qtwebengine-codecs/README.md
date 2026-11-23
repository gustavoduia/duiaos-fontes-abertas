# Qt WebEngine com os codecs H.264, AAC e MP3

O motor web do Ora (navegador) e do Mail Box (e-mail) do DuiaOS é o Qt WebEngine (Chromium). As rodas
oficiais do PySide6 trazem o Qt WebEngine **sem** os codecs proprietários, e por isso vídeos em H.264
(com áudio AAC) não tocavam. O DuiaOS o compila do código-fonte oficial, **sem alterar nenhum arquivo**,
só ligando a opção que o próprio Qt oferece.

| | |
| --- | --- |
| Componente | Qt WebEngine 6.140.0 (baseado no Chromium 140, com correções de segurança do Chromium mais novo) |
| Código-fonte | <https://download.qt.io/official_releases/qtwebengine/6.140/6.140.0/src/qtwebengine-everywhere-src-6.140.0.tar.xz> (conferido pelo `md5sums.txt` publicado ao lado) |
| Licença | LGPL-3.0-only (Qt WebEngine); os componentes do Chromium seguem as licenças deles, que vão junto |
| Alterações no código | nenhuma |
| Opções de compilação | `-DFEATURE_webengine_proprietary_codecs=ON` (FFmpeg embutido do Chromium com H.264, AAC e MP3), `-DFEATURE_webengine_system_ffmpeg=OFF`, `-DFEATURE_qtpdf_build=OFF` |
| Para | Qt 6.12.0 (o das rodas do PySide6 6.12.0), Debian 13, amd64 e arm64 |
| Receita | [`construir.sh`](construir.sh) e o workflow [`motor-web-codecs.yml`](../../.github/workflows/motor-web-codecs.yml) |
| Resultado | Releases `motor-web-codecs-*` deste repositório |

Para reproduzir num Debian 13 (precisa de muitas horas, ~16 GB de memória e ~60 GB de disco):

```bash
sudo docker run --rm -v /caminho/build:/build -v "$PWD":/receita debian:trixie bash -c '
  bash /receita/modificacoes/qtwebengine-codecs/construir.sh preparar &&
  bash /receita/modificacoes/qtwebengine-codecs/construir.sh compilar 999999 &&
  bash /receita/modificacoes/qtwebengine-codecs/construir.sh empacotar /receita/saida'
```

Sobre patentes: H.264 e AAC são cobertos por patentes em alguns países; a decisão de distribuí-los no
DuiaOS foi do responsável pelo projeto (23/11/2026), como fazem outras distribuições e o Chrome.
