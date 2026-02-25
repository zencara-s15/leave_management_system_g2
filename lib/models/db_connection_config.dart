class DbConnectionConfig {
  const DbConnectionConfig({
    required this.host,
    required this.port,
    required this.user,
    required this.password,
    required this.database,
  });

  final String host;
  final int port;
  final String user;
  final String password;
  final String database;

  factory DbConnectionConfig.fromJson(Map<String, dynamic> json) {
    return DbConnectionConfig(
      host: json['host'] as String,
      port: json['port'] as int,
      user: json['user'] as String,
      password: json['password'] as String,
      database: json['database'] as String,
    );
  }
}
