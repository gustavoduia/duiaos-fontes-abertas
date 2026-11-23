#!/bin/bash
# =============================================================================
# DuiaOS — Qt WebEngine (Chromium) com os codecs H.264, AAC e MP3 (ADR 078 do DuiaOS).
#
# O Qt WebEngine das rodas oficiais do PySide6 (o motor web do Ora e do Mail Box) vem sem os
# codecs proprietários: vídeos em H.264 não tocam. Aqui ele é compilado do código-fonte oficial,
# SEM nenhuma alteração no código, só com a opção do próprio Qt:
#     -DQT_FEATURE_webengine_proprietary_codecs=ON   (FFmpeg embutido do Chromium com H.264/AAC/MP3)
# e sem o Qt PDF (o do PySide6 continua). O resultado substitui no pacote duiaos-motor-web as
# bibliotecas do Qt WebEngine (Core e Quick), o módulo QML, o QtWebEngineProcess e os recursos.
#
# Roda DENTRO de um Debian 13 (container debian:trixie) da arquitetura de destino, como root, em
# etapas (a compilação leva muitas horas; o GitHub Actions corta cada job em 6 h):
#   construir.sh preparar            dependências, Qt 6.12.0 (aqtinstall), código-fonte, cmake
#   construir.sh compilar SEGUNDOS   compila por até SEGUNDOS; sai com 0 quando termina, 99 se parou
#   construir.sh empacotar SAIDA     instala e junta as peças em SAIDA/qtwebengine-codecs-VERSAO-ARQ.tar.xz
# Tudo fica em /build (o workflow guarda /build/obj e /build/qt de uma etapa para a outra).
#
# Licença do Qt WebEngine: LGPL-3.0-only (e as dos componentes do Chromium, que vão junto).
# Código-fonte: https://download.qt.io/official_releases/qtwebengine/ (versão e soma abaixo).
# =============================================================================
set -euo pipefail

QTWEBENGINE=6.140.0
QTWEBENGINE_SERIE=6.140
QTWEBENGINE_MD5_URL="https://download.qt.io/official_releases/qtwebengine/${QTWEBENGINE_SERIE}/${QTWEBENGINE}/src/md5sums.txt"
FONTE_URL="https://download.qt.io/official_releases/qtwebengine/${QTWEBENGINE_SERIE}/${QTWEBENGINE}/src/qtwebengine-everywhere-src-${QTWEBENGINE}.tar.xz"
QT=6.12.0                                  # o Qt das rodas do PySide6 6.12.0 (pacotes/duiaos-motor-web/VERSAO)
B=/build

case "$(dpkg --print-architecture)" in
  amd64) ARQ=amd64; AQT_HOST=linux; AQT_ARCH=linux_gcc_64; QTDIR="${B}/qt/${QT}/gcc_64" ;;
  arm64) ARQ=arm64; AQT_HOST=linux_arm64; AQT_ARCH=linux_gcc_arm64; QTDIR="${B}/qt/${QT}/gcc_arm64" ;;
  *) echo "Arquitetura não suportada" >&2; exit 1 ;;
esac

dependencias() {
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq
  # Plataforma do Qt WebEngine no Linux (doc.qt.io, "Qt WebEngine Platform Notes"). Sem as -dev de
  # libwebp, opus, vpx, icu, snappy e afins: o Chromium usa as cópias dele (o pacote fica independente
  # das versões do sistema), e o FFmpeg tem de ser o embutido para os codecs proprietários.
  apt-get install -y -qq --no-install-recommends \
    build-essential cmake ninja-build lld pkg-config python3 python3-venv python3-html5lib nodejs gperf bison flex \
    git ca-certificates curl xz-utils zstd file patchelf \
    libnss3-dev libnspr4-dev libdbus-1-dev libfontconfig-dev libfreetype-dev libexpat1-dev libglib2.0-dev \
    libx11-dev libx11-xcb-dev libxcb1-dev libxcomposite-dev libxcursor-dev libxdamage-dev libxext-dev libxfixes-dev \
    libxi-dev libxrandr-dev libxrender-dev libxtst-dev libxshmfence-dev libxkbfile-dev libxkbcommon-dev \
    libxkbcommon-x11-dev libdrm-dev libgbm-dev libegl-dev libgl-dev libgles-dev libudev-dev \
    libasound2-dev libpulse-dev libcups2-dev libkrb5-dev >/dev/null
}

preparar() {
  dependencias
  mkdir -p "${B}"
  # Qt 6.12.0 oficial (cabeçalhos e CMake; as mesmas bibliotecas que vêm nas rodas do PySide6)
  if [ ! -d "${QTDIR}" ]; then
    python3 -m venv "${B}/aqt-venv"
    "${B}/aqt-venv/bin/pip" install -q aqtinstall
    "${B}/aqt-venv/bin/aqt" version
    "${B}/aqt-venv/bin/aqt" install-qt "${AQT_HOST}" desktop "${QT}" "${AQT_ARCH}" \
      -m qtwebchannel qtpositioning -O "${B}/qt"
  fi
  [ -f "${QTDIR}/lib/cmake/Qt6/qt.toolchain.cmake" ] || { echo "Qt ${QT} não instalado em ${QTDIR}" >&2; exit 1; }
  fonte
  if [ ! -f "${B}/obj/build.ninja" ]; then
    cmake -S "${B}/src" -B "${B}/obj" -G Ninja \
      -DCMAKE_TOOLCHAIN_FILE="${QTDIR}/lib/cmake/Qt6/qt.toolchain.cmake" \
      -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${B}/inst" \
      -DQT_FEATURE_webengine_proprietary_codecs=ON \
      -DQT_FEATURE_webengine_system_ffmpeg=OFF \
      -DQT_FEATURE_qtpdf_build=OFF \
      -DQT_FEATURE_use_lld_linker=ON \
      -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_TESTS=OFF
  fi
  grep -q 'webengine_proprietary_codecs:BOOL=ON\|FEATURE_webengine_proprietary_codecs:BOOL=ON' "${B}/obj/CMakeCache.txt" \
    || { echo "O cmake não ligou os codecs proprietários" >&2; exit 1; }
}

fonte() {
  # Código-fonte oficial, conferido pela soma publicada pelo Qt. Extraído sempre igual (as datas dos
  # arquivos vêm do pacote), para a compilação continuar de onde parou na etapa seguinte.
  if [ ! -f "${B}/src/CMakeLists.txt" ]; then
    mkdir -p "${B}/download"
    local ARQUIVO="${B}/download/qtwebengine-everywhere-src-${QTWEBENGINE}.tar.xz"
    [ -f "${ARQUIVO}" ] || curl -fsSL --retry 5 -o "${ARQUIVO}" "${FONTE_URL}"
    local SOMA
    SOMA="$(curl -fsSL --retry 5 "${QTWEBENGINE_MD5_URL}" | awk '/\.tar\.xz$/ {print $1}')"
    echo "${SOMA}  ${ARQUIVO}" | md5sum -c - >/dev/null || { echo "Soma do código-fonte não confere" >&2; exit 1; }
    mkdir -p "${B}/src"
    tar -xJf "${ARQUIVO}" -C "${B}/src" --strip-components=1
    rm -f "${ARQUIVO}"
  fi
}

compilar() {
  local LIMITE="${1:?Uso: construir.sh compilar SEGUNDOS}"
  dependencias
  fonte
  [ -f "${B}/obj/build.ninja" ] || { echo "Rode 'preparar' antes" >&2; exit 1; }
  local JOBS
  JOBS="$(nproc)"
  # Cada processo do compilador do Chromium chega a ~2 GB: não passar da memória
  local MEMORIA_GB=$(( $(awk '/MemTotal/ {print $2}' /proc/meminfo) / 1024 / 1024 ))
  [ $(( MEMORIA_GB / 2 )) -lt "${JOBS}" ] && JOBS=$(( MEMORIA_GB / 2 > 0 ? MEMORIA_GB / 2 : 1 ))
  echo "==> compilando com ${JOBS} processos por até ${LIMITE} s"
  # Em grupo de processos próprio: ao fim do tempo, o Ctrl+C vai para o ninja de fora e o de dentro (Chromium)
  setsid cmake --build "${B}/obj" --parallel "${JOBS}" &
  local PID=$! FIM=$(( SECONDS + LIMITE ))
  while kill -0 "${PID}" 2>/dev/null; do
    if [ "${SECONDS}" -ge "${FIM}" ]; then
      echo "==> tempo da etapa acabou: parando para continuar na próxima"
      kill -INT -- "-${PID}" 2>/dev/null || true
      for _ in $(seq 1 120); do kill -0 "${PID}" 2>/dev/null || break; sleep 1; done
      kill -KILL -- "-${PID}" 2>/dev/null || true
      wait "${PID}" 2>/dev/null || true
      exit 99
    fi
    sleep 20
  done
  wait "${PID}"
  touch "${B}/obj/.duiaos-pronto"
  echo "==> compilação terminada"
}

empacotar() {
  local SAIDA="${1:?Uso: construir.sh empacotar SAIDA}"
  [ -f "${B}/obj/.duiaos-pronto" ] || { echo "A compilação não terminou" >&2; exit 1; }
  rm -rf "${B}/inst"
  cmake --install "${B}/obj" --prefix "${B}/inst" >/dev/null
  local P="${B}/pacote/Qt"
  rm -rf "${B}/pacote"
  mkdir -p "${P}/lib" "${P}/qml" "${P}/translations" "${SAIDA}"
  # Todas as bibliotecas do Qt WebEngine (Core, Quick, Widgets...): elas usam partes internas umas das outras
  cp -a "${B}/inst"/lib/libQt6WebEngine*.so* "${P}/lib/"
  cp -a "${B}/inst/qml/QtWebEngine" "${P}/qml/"
  cp -a "${B}/inst/libexec" "${B}/inst/resources" "${P}/"
  cp -a "${B}/inst/translations/qtwebengine_locales" "${P}/translations/"
  # As rodas do PySide6 procuram as bibliotecas pelo $ORIGIN (sem caminho de compilação gravado)
  for F in "${P}"/lib/libQt6WebEngine*.so.6.* "${P}/libexec/QtWebEngineProcess"; do
    [ -L "${F}" ] && continue
    patchelf --set-rpath "\$ORIGIN:\$ORIGIN/../lib" "${F}"
  done
  find "${P}/qml" -name '*.so' -exec patchelf --set-rpath "\$ORIGIN/../../lib" {} \;
  strip --strip-unneeded "${P}"/lib/libQt6WebEngine*.so.6.* "${P}/libexec/QtWebEngineProcess" 2>/dev/null || true
  # Conferência: o Chromium foi gerado com os codecs proprietários (args.gn do GN, feito pelo cmake)
  grep -rqs 'proprietary_codecs *= *true' "${B}/obj/src/core" --include=args.gn \
    || { echo "O Chromium não foi gerado com proprietary_codecs = true" >&2; exit 1; }
  local NOME="qtwebengine-codecs-${QTWEBENGINE}-qt${QT}-${ARQ}"
  {
    echo "Qt WebEngine ${QTWEBENGINE} (Chromium), compilado pelo DuiaOS para Qt ${QT}, Debian 13 ${ARQ}."
    echo "Código-fonte sem alterações: ${FONTE_URL}"
    echo "Opções: -DQT_FEATURE_webengine_proprietary_codecs=ON -DQT_FEATURE_webengine_system_ffmpeg=OFF -DQT_FEATURE_qtpdf_build=OFF"
    echo "Receita: https://github.com/gustavoduia/duiaos-fontes-abertas/tree/main/modificacoes/qtwebengine-codecs"
    echo "Licença: LGPL-3.0-only (Qt WebEngine) e as licenças do Chromium em resources/ e na documentação do Qt."
  } > "${B}/pacote/LEIA-ME.txt"
  tar -C "${B}/pacote" -cJf "${SAIDA}/${NOME}.tar.xz" Qt LEIA-ME.txt
  (cd "${SAIDA}" && sha256sum "${NOME}.tar.xz" > "${NOME}.tar.xz.sha256")
  ls -la "${SAIDA}"
}

ACAO="${1:?Uso: construir.sh preparar | compilar SEGUNDOS | empacotar SAIDA}"
shift
case "${ACAO}" in
  preparar) preparar ;;
  compilar) compilar "$@" ;;
  empacotar) empacotar "$@" ;;
  *) echo "Ação desconhecida: ${ACAO}" >&2; exit 1 ;;
esac
