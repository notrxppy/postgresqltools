class ConnectionConfig {
  final String host;
  final int port;
  final String database;
  final String username;
  final String password;
  final String? connectionName;

  ConnectionConfig({
    required this.host,
    required this.port,
    required this.database,
    required this.username,
    required this.password,
    this.connectionName,
  });

  Map<String, dynamic> toMap() {
    return {
      'host': host,
      'port': port,
      'database': database,
      'username': username,
      'password': password,
      'connectionName': connectionName,
    };
  }

  factory ConnectionConfig.fromMap(Map<String, dynamic> map) {
    return ConnectionConfig(
      host: map['host'],
      port: map['port'],
      database: map['database'],
      username: map['username'],
      password: map['password'],
      connectionName: map['connectionName'],
    );
  }

  String get connectionString {
    return 'postgresql://$username:${_maskPassword(password)}@$host:$port/$database';
  }

  String _maskPassword(String password) {
    return '*' * password.length;
  }

  ConnectionConfig copyWith({
    String? host,
    int? port,
    String? database,
    String? username,
    String? password,
    String? connectionName,
  }) {
    return ConnectionConfig(
      host: host ?? this.host,
      port: port ?? this.port,
      database: database ?? this.database,
      username: username ?? this.username,
      password: password ?? this.password,
      connectionName: connectionName ?? this.connectionName,
    );
  }
}
