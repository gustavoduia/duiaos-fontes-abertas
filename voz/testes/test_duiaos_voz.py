# SPDX-License-Identifier: GPL-3.0-or-later
"""Testes do duiaos-voz (rodar: python3 -m unittest discover -s voz/testes -t .).

Sem modelos de voz: o texto falado, o fim da vez da pessoa e a fila de trechos com um sintetizador e um
tocador de mentira (o tocador só conta o tempo de áudio que recebeu).
"""
import importlib.machinery
import importlib.util
import os
import queue
import tempfile
import threading
import time
import unittest
from pathlib import Path
from unittest import mock

PROGRAMA = Path(__file__).resolve().parents[1] / "duiaos-voz"


def carregar():
    carregador = importlib.machinery.SourceFileLoader("duiaos_voz", str(PROGRAMA))
    modulo = importlib.util.module_from_spec(importlib.util.spec_from_loader("duiaos_voz", carregador))
    carregador.exec_module(modulo)
    return modulo


dv = carregar()


class TestTextoFalado(unittest.TestCase):
    def test_numeros_horas_e_dinheiro_como_se_fala(self):
        self.assertEqual(dv.preparar_texto("Agora faz 26 °C e 80% de umidade."), "Agora faz 26 graus e 80 por cento de umidade.")
        self.assertEqual(dv.preparar_texto("São 1.430 MB."), "São 1430 megabytes.")
        self.assertEqual(dv.preparar_texto("Às 14:30, às 9h e às 8:00."), "Às 14 horas e 30, às 9 horas e às 8 horas.")
        self.assertEqual(dv.preparar_texto("Custa R$ 10,50 ou R$ 1,00."), "Custa 10 reais e 50 centavos ou 1 real.")
        self.assertEqual(dv.preparar_texto("O IP é 192.168.0.1, versão 1.2.3."), "O IP é 192.168.0.1, versão 1.2.3.")

    def test_pausa_pela_pontuacao(self):
        self.assertGreater(dv.pausa_depois("Tudo bem?"), dv.pausa_depois("Tudo bem."))
        self.assertGreater(dv.pausa_depois("Tudo bem."), dv.pausa_depois("faz 26 graus,"))
        self.assertEqual(dv.pausa_depois("sem pontuação"), dv.PAUSA_SEM_PONTUACAO)


class TestFimDaVez(unittest.TestCase):
    def test_palavra_que_pede_continuacao(self):
        self.assertTrue(dv.termina_em_continuacao("Abre o VLC e."))          # o reconhecimento pontua tudo
        self.assertTrue(dv.termina_em_continuacao("Me fala uma coisa, tipo"))
        self.assertFalse(dv.termina_em_continuacao("Quero saber o tempo amanhã."))
        self.assertFalse(dv.termina_em_continuacao("Tudo bem, né?"))
        self.assertFalse(dv.termina_em_continuacao(""))


class AudioFalso:
    def __init__(self, segundos, taxa=24000):
        self.samples = [0.1] * int(segundos * taxa)
        self.sample_rate = taxa


class TestFalante(unittest.TestCase):
    def test_trechos_num_fluxo_so_e_fim_quando_o_som_acaba(self):
        """Um tocador para a fala inteira (e para a próxima), cada trecho com a pausa da pontuação, e o fim da
        fala avisado só quando o último som termina de tocar."""
        eventos, abertos, recebido = queue.Queue(), [], []

        class Tocador:
            def __init__(self):
                self.stdin = self

            def write(self, dados):
                recebido.append(len(dados))

            def flush(self):
                pass

            def close(self):
                pass

            def poll(self):
                return None

            def kill(self):
                pass

            def wait(self, timeout=None):
                return 0

        class Modelo:
            def generate(self, texto, sid=0, speed=1.0):
                return AudioFalso(0.3)

        with mock.patch.object(dv, "tocador", lambda taxa: abertos.append(taxa) or Tocador()), \
                mock.patch.object(dv, "dizer", lambda **d: eventos.put(d)), \
                mock.patch.object(dv, "voz_disponivel", lambda nome: "dora"), \
                mock.patch.object(dv, "criar_voz", lambda nome: (Modelo(), 0)):
            falante = dv.Falante()
            inicio = time.monotonic()
            for trecho in ("Claro!", "Agora faz 26 graus,", "com céu nublado."):
                falante.falar("f1", trecho, "dora", 1.0)
            falante.concluir("f1")
            fim = None
            while fim is None:
                evento = eventos.get(timeout=10)
                if evento.get("evento") == "fim_fala":
                    fim = evento
            duracao = time.monotonic() - inicio
            falante.falar("f2", "De novo.", "dora", 1.0)
            falante.concluir("f2")
            while eventos.get(timeout=10).get("evento") != "fim_fala":
                pass
        self.assertEqual(fim["frases"], 3)
        self.assertEqual(abertos, [24000])                                # um tocador só, para as duas falas
        som = 3 * 0.3 + dv.PAUSAS["!"] + dv.PAUSAS[","] + dv.PAUSAS["."]
        self.assertAlmostEqual(sum(recebido[:3]) / 2 / 24000, som, places=2)
        self.assertGreaterEqual(duracao, som - 0.05)                      # o fim espera o som tocar


class TestKokoroAntigo(unittest.TestCase):
    def test_int8_continua_valendo_ate_baixar_o_rapido(self):
        with tempfile.TemporaryDirectory() as pasta, mock.patch.object(dv, "PASTA", Path(pasta)):
            kokoro = Path(pasta) / "kokoro"
            kokoro.mkdir()
            for nome in ("model.int8.onnx", "voices.bin", "tokens.txt", "lexicon-us-en.txt"):
                (kokoro / nome).write_text("x")
            (kokoro / "espeak-ng-data").mkdir()
            self.assertTrue(dv.instalado("kokoro"))
            self.assertTrue(dv.kokoro_antigo())
            (kokoro / "model.onnx").write_text("x")
            self.assertFalse(dv.kokoro_antigo())
            self.assertTrue(dv.instalado("kokoro"))


if __name__ == "__main__":
    unittest.main()
