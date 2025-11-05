import 'package:postgres/postgres.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  late final Connection _connection;
  bool _isInitialized = false;

  Future<Connection> get connection async {
    if (!_isInitialized) {
      await init();
    }
    return _connection;
  }

  Future<void> init() async {
    if (_isInitialized) return;

    _connection = await Connection.open(
      Endpoint(
        host: 'caboose.proxy.rlwy.net',
        port: 33798,
        database: 'railway',
        username: 'postgres',
        password: 'FIgNRBgScLQRHJoLDtGMTpSSkcOnpJKI',
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );
    // _connection = await Connection.open(
    //   Endpoint(
    //     host: 'localhost',
    //     database: 'todos',
    //     username: 'postgres',
    //     password: 'Hack@berry17',
    //   ),
    //   settings: const ConnectionSettings(sslMode: SslMode.disable),
    // );

    _isInitialized = true;

    await _connection.execute('''
  CREATE TABLE IF NOT EXISTS todos (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    text TEXT NOT NULL,
    user_id INT,
    is_liked BOOLEAN DEFAULT FALSE
  );
''');

    print('✅ PostgreSQL connected (global)');
  }
}
