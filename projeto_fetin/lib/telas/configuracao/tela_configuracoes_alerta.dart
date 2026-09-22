import 'package:flutter/material.dart';

import '../../servicos/configuracoes_alerta_service.dart';
import 'package:projeto_fetin/tema/app_cores.dart';

class TelaConfiguracoesAlerta extends StatefulWidget {
  const TelaConfiguracoesAlerta({
    super.key,
  });

  @override
  State<TelaConfiguracoesAlerta> createState() =>
      _TelaConfiguracoesAlertaState();
}

class _TelaConfiguracoesAlertaState
    extends State<TelaConfiguracoesAlerta> {

  // Valores exibidos nos botões da tela.
  bool somLigado = true;
  bool vibracaoLigada = true;

  // Enquanto as configurações estão sendo carregadas,
  // mostramos um indicador de carregamento.
  bool carregando = true;

  @override
  void initState() {
    super.initState();

    carregarConfiguracoes();
  }

  Future<void> carregarConfiguracoes() async {
    // Busca as preferências salvas no celular.
    final som =
        await ConfiguracoesAlertaService.carregarSom();

    final vibracao =
        await ConfiguracoesAlertaService.carregarVibracao();

    if (!mounted) {
      return;
    }

    setState(() {
      somLigado = som;
      vibracaoLigada = vibracao;
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text(
          "Configurações do alerta",
        ),
        backgroundColor: Colors.grey.shade100,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: carregando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [
                  // -------------------------
                  // SOM
                  // -------------------------

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(18),
                    ),

                    child: SwitchListTile(
                      value: somLigado,

                      secondary: const Icon(
                        Icons.volume_up_outlined,
                        color: AppCores.roxoMeioTermo,
                      ),

                      title: const Text(
                        "Som do alerta",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: const Text(
                        "Reproduzir som quando houver "
                        "risco de afastamento.",
                      ),

                      activeColor:
                          AppCores.roxoMeioTermo,

                      onChanged: (valor) async {
                        setState(() {
                          somLigado = valor;
                        });

                        // Salva a escolha no celular.
                        await ConfiguracoesAlertaService
                            .salvarSom(valor);
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // -------------------------
                  // VIBRAÇÃO
                  // -------------------------

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(18),
                    ),

                    child: SwitchListTile(
                      value: vibracaoLigada,

                      secondary: const Icon(
                        Icons.vibration,
                        color: AppCores.roxoMeioTermo,
                      ),

                      title: const Text(
                        "Vibração",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: const Text(
                        "Vibrar o celular quando houver "
                        "risco de afastamento.",
                      ),

                      activeColor:
                          AppCores.roxoMeioTermo,

                      onChanged: (valor) async {
                        setState(() {
                          vibracaoLigada = valor;
                        });

                        // Salva a escolha no celular.
                        await ConfiguracoesAlertaService
                            .salvarVibracao(valor);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}