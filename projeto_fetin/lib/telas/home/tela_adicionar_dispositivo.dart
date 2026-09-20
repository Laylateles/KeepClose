import 'package:flutter/material.dart';
import 'tela_nomear_dispositivo.dart';
import '../modelo/dispositivo_modelo.dart';
import 'package:projeto_fetin/tema/app_cores.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../servicos/bluetooth_service.dart';
import 'dart:async';

class TelaAdicionarDispositivo extends StatefulWidget {
  final List<String> idsCadastrados;
  final int usuarioId;

  const TelaAdicionarDispositivo({
    super.key,
    required this.idsCadastrados,
    required this.usuarioId,
  });

  @override
  State<TelaAdicionarDispositivo> createState() =>
      _TelaAdicionarDispositivoState();
}

class _TelaAdicionarDispositivoState extends State<TelaAdicionarDispositivo> {
  final BluetoothServiceKeepClose bluetooth =
      BluetoothServiceKeepClose.instancia;

  StreamSubscription<BluetoothAdapterState>? assinaturaBluetooth;
  bool bluetoothLigado = false;
  @override
  void initState() {
    super.initState();

    bluetoothLigado =
        FlutterBluePlus.adapterStateNow == BluetoothAdapterState.on;
    iniciarBusca();

  assinaturaBluetooth =
      FlutterBluePlus.adapterState.listen((estado) {
    if (!mounted) {
      return;
    }

    final ligado =
        estado == BluetoothAdapterState.on;

    setState(() {
      bluetoothLigado = ligado;
    });

    if (ligado) {
      iniciarBusca();
    } else {
      bluetooth.pararBusca();
    }
  });
  }

  Future<void> iniciarBusca() async {
    try {
      await bluetooth.iniciarBusca();
    } catch (erro) {
      print("ERRO AO INICIAR BUSCA: $erro");
    }
  }

  @override
  void dispose() {
    assinaturaBluetooth?.cancel();
    bluetooth.pararBusca();
    super.dispose();
  }

  Future<void> conectarDispositivo(BluetoothDevice device) async {
    try {
      await bluetooth.pararBusca();

      print("Tentando conectar em: ${device.remoteId.str}");

      await bluetooth.conectar(device);

      print("ESP32 conectado com sucesso!");

      if (!mounted) {
        return;
      }

      final dispositivo = await Navigator.push<DispositivoModelo>(
        context,
        MaterialPageRoute(
          builder: (context) => TelaNomearDispositivo(
            idBluetooth: device.remoteId.str,
            usuarioId: widget.usuarioId,
          ),
        ),
      );

      if (dispositivo != null && mounted) {
        Navigator.pop(context, dispositivo);
      }
    } catch (erro) {
      print("ERRO AO CONECTAR: $erro");

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Não foi possível conectar à tag: $erro")),
      );

      await bluetooth.iniciarBusca();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                ),
              ),

              const SizedBox(height: 10),

              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppCores.roxoMeioTermo,
                    size: 38,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "KeepClose",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppCores.roxoMeioTermo,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              const Text(
                "Adicionar dispositivo",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                "Procure uma tag KeepClose próxima para conectá-la ao aplicativo.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: AppCores.cinza,
                ),
              ),
              const SizedBox(height: 35),
              if (!bluetoothLigado)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.bluetooth_disabled, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Bluetooth desligado. Ligue o Bluetooth para procurar sua tag KeepClose.",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

              if (bluetoothLigado) ...[
                const CircularProgressIndicator(color: AppCores.roxoMeioTermo),
                const SizedBox(height: 20),
                const Text(
                  "Procurando tags próximas...",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
              const SizedBox(height: 30),

              StreamBuilder<List<ScanResult>>(
                stream: bluetooth.resultadosScan,
                builder: (context, snapshot) {
                  if (!bluetoothLigado) {
                    return const SizedBox.shrink();
                  }
                  final resultados = snapshot.data ?? [];

                  for (final resultado in resultados) {
                    print(
                      "BLE encontrado: "
                      "${resultado.advertisementData.advName} | "
                      "${resultado.device.remoteId.str}",
                    );
                  }

                  final disponiveis = resultados.where((resultado) {
                    final id = resultado.device.remoteId.str;
                    final nomeAnunciado = resultado.advertisementData.advName;

                    final ehKeepClose = nomeAnunciado.toUpperCase().startsWith(
                      "KEEPCLOSE_", //KEEP_CLOSE",
                    );

                    final jaCadastrado = widget.idsCadastrados.contains(id);

                    print(
                      "Nome: $nomeAnunciado | "
                      "KeepClose: $ehKeepClose | "
                      "Já cadastrado: $jaCadastrado",
                    );

                    return ehKeepClose && !jaCadastrado;
                  }).toList();

                  if (disponiveis.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text("Nenhuma tag KeepClose encontrada."),
                    );
                  }

                  return Column(
                    children: disponiveis.map((resultado) {
                      final device = resultado.device;
                      final nome =
                          resultado.advertisementData.advName.isNotEmpty
                          ? resultado.advertisementData.advName
                          : device.remoteId.str;

                      print(
                        "Encontrado: "
                        "${resultado.advertisementData.advName} | "
                        "${resultado.device.remoteId.str} | "
                        "RSSI ${resultado.rssi}",
                      );

                      return ListTile(
                        leading: const Icon(
                          Icons.bluetooth,
                          color: AppCores.roxoMeioTermo,
                        ),
                        title: Text(nome),
                        subtitle: Text("Sinal: ${resultado.rssi} dBm"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () async {
                          await conectarDispositivo(device);
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
