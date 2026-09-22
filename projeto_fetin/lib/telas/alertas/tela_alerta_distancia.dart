import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../servicos/configuracoes_alerta_service.dart';

class TelaAlertaDistancia extends StatefulWidget {
  final String nomeDispositivo;

  const TelaAlertaDistancia({
    super.key,
    required this.nomeDispositivo,
  });

  @override
  State<TelaAlertaDistancia> createState() =>
      _TelaAlertaDistanciaState();
}

class _TelaAlertaDistanciaState
    extends State<TelaAlertaDistancia> {

  // Player responsável pelo som do alerta.
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    // Quando a tela abrir, inicia o alerta.
    iniciarAlerta();
  }

  Future<void> iniciarAlerta() async {
    // Carrega as escolhas que o usuário fez
    // na tela de configurações.
    final somLigado =
        await ConfiguracoesAlertaService.carregarSom();

    final vibracaoLigada =
        await ConfiguracoesAlertaService.carregarVibracao();

    if (!mounted) {
      return;
    }

    // -------------------------
    // VIBRAÇÃO
    // -------------------------

    // Só vibra se o usuário deixou
    // a opção de vibração ligada.
    if (vibracaoLigada) {
      final possuiVibrador =
          await Vibration.hasVibrator();

      if (possuiVibrador) {
        Vibration.vibrate(
          pattern: [0, 700, 500, 700],
          repeat: 0,
        );
      }
    }

    // -------------------------
    // SOM
    // -------------------------

    // Só toca o áudio se o usuário
    // deixou o som ligado.
    if (somLigado) {
      await audioPlayer.setReleaseMode(
        ReleaseMode.loop,
      );

      await audioPlayer.play(
        AssetSource(
          'audios/alerta_keepclose.wav',
        ),
      );
    }
  }

  Future<void> pararAlerta() async {
    // Para a vibração.
    await Vibration.cancel();

    // Para o som.
    await audioPlayer.stop();

    if (!mounted) {
      return;
    }

    // Fecha a tela de alerta.
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // Segurança:
    // se a tela for fechada de outra forma,
    // som e vibração também são interrompidos.
    Vibration.cancel();

    audioPlayer.stop();
    audioPlayer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB3261E),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 32,
          ),

          child: Column(
            children: [
              const Spacer(),

              // Ícone principal do alerta.
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 80,
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                "ALERTA DE AFASTAMENTO",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                "Você está se afastando de\n"
                "${widget.nomeDispositivo}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "O sinal Bluetooth atingiu "
                "uma região crítica.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 17,
                  height: 1.4,
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: pararAlerta,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor:
                        const Color(0xFFB3261E),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),

                  child: const Text(
                    "DESATIVAR ALERTA",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}