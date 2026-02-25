import 'dart:io';

import 'package:mysql1/mysql1.dart';

import '../models/db_connection_config.dart';

class DatabaseException implements Exception {
  const DatabaseException(this.message);

  final String message;

  @override
  String toString() => message;
}

class MySqlService {
  const MySqlService(this.config);

  final DbConnectionConfig config;

  Future<String> testConnection() async {
    MySqlConnection? connection;

    try {
      connection = await MySqlConnection.connect(
        ConnectionSettings(
          host: config.host,
          port: config.port,
          user: config.user,
          password: config.password,
          db: config.database,
          timeout: const Duration(seconds: 10),
        ),
      );

      final result = await connection.query('SELECT NOW() AS server_time');
      final row = result.first;
      final serverTime = row['server_time'];

      return 'Connected successfully. Server time: $serverTime';
    } on SocketException catch (error) {
      throw DatabaseException('Network error: ${error.message}');
    } on MySqlException catch (error) {
      throw DatabaseException(
        'MySQL error ${error.errorNumber}: ${error.message}',
      );
    } catch (error) {
      throw DatabaseException('Unexpected error: $error');
    } finally {
      await connection?.close();
    }
  }
}
