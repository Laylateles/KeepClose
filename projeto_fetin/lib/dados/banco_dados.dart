import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../telas/modelo/usuario_modelo.dart';
import '../telas/modelo/dispositivo_modelo.dart';

class BancoDados {
  BancoDados._();

  static final BancoDados instancia = BancoDados._();

  static const String nomeBanco = 'keepclose.db';
  static const int versaoBanco = 1;

  Database? _banco;

  Future<Database> get banco async {
    if (_banco != null) {
      return _banco!;
    }

    _banco = await _abrirBanco();
    return _banco!;
  }

  Future<Database> _abrirBanco() async {
    final pastaBancos = await getDatabasesPath();
    final caminhoBanco = join(pastaBancos, nomeBanco);

    return openDatabase(
      caminhoBanco,
      version: versaoBanco,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _criarTabelas,
    );
  }

  Future<void> _criarTabelas(Database db, int version) async {
    await db.execute('''
    CREATE TABLE usuarios (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      senha_hash TEXT NOT NULL
    )
  ''');

    await db.execute('''
  CREATE TABLE dispositivos (
    id_bluetooth TEXT PRIMARY KEY,
    usuario_id INTEGER NOT NULL,
    nome TEXT NOT NULL,
    conectado INTEGER NOT NULL DEFAULT 0,
    distancia TEXT NOT NULL DEFAULT 'Calculando...',
    ultima_conexao TEXT NOT NULL DEFAULT 'Agora',
    rssi INTEGER,
    proximidade TEXT NOT NULL DEFAULT 'Aguardando sinal',

    FOREIGN KEY (usuario_id)
      REFERENCES usuarios (id)
      ON DELETE CASCADE
  )
''');
  }

  Future<int> cadastrarUsuario(UsuarioModelo usuario) async {
    final db = await banco;

    return db.insert(
      'usuarios',
      usuario.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<UsuarioModelo?> buscarUsuarioPorEmail(String email) async {
    final db = await banco;

    final resultado = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (resultado.isEmpty) {
      return null;
    }

    return UsuarioModelo.fromMap(resultado.first);
  }

  Future<void> salvarDispositivo(DispositivoModelo dispositivo) async {
    final db = await banco;

    await db.insert(
      'dispositivos',
      dispositivo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DispositivoModelo>> buscarDispositivosDoUsuario(
    int usuarioId,
  ) async {
    final db = await banco;

    final resultado = await db.query(
      'dispositivos',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'nome ASC',
    );

    return resultado.map((map) => DispositivoModelo.fromMap(map)).toList();
  }

  Future<void> renomearDispositivo({
    required String idBluetooth,
    required int usuarioId,
    required String novoNome,
  }) async {
    final db = await banco;

    await db.update(
      'dispositivos',
      {'nome': novoNome},
      where: 'id_bluetooth = ? AND usuario_id = ?',
      whereArgs: [idBluetooth, usuarioId],
    );
  }

  Future<void> excluirDispositivo({
    required String idBluetooth,
    required int usuarioId,
  }) async {
    final db = await banco;

    await db.delete(
      'dispositivos',
      where: 'id_bluetooth = ? AND usuario_id = ?',
      whereArgs: [idBluetooth, usuarioId],
    );
  }
}
