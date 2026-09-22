import 'package:shared_preferences/shared_preferences.dart';

class ConfiguracoesAlertaService {
  // Chaves usadas para salvar as configurações no celular.
  static const String _chaveSom = 'som_alerta';
  static const String _chaveVibracao = 'vibracao_alerta';

  // Salva se o som do alerta está ligado ou desligado.
  static Future<void> salvarSom(bool ligado) async {
    final preferencias =
        await SharedPreferences.getInstance();

    await preferencias.setBool(
      _chaveSom,
      ligado,
    );
  }

  // Retorna a configuração salva do som.
  //
  // Se o usuário nunca alterou essa opção,
  // o padrão será true: som ligado.
  static Future<bool> carregarSom() async {
    final preferencias =
        await SharedPreferences.getInstance();

    return preferencias.getBool(_chaveSom) ?? true;
  }

  // Salva se a vibração está ligada ou desligada.
  static Future<void> salvarVibracao(bool ligada) async {
    final preferencias =
        await SharedPreferences.getInstance();

    await preferencias.setBool(
      _chaveVibracao,
      ligada,
    );
  }

  // Retorna a configuração salva da vibração.
  //
  // Se o usuário nunca alterou essa opção,
  // o padrão será true: vibração ligada.
  static Future<bool> carregarVibracao() async {
    final preferencias =
        await SharedPreferences.getInstance();

    return preferencias.getBool(
      _chaveVibracao,
    ) ?? true;
  }
}