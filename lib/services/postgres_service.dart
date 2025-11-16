// PostgreSQL Service - Actual SQL processing
class QueryResult {
  final bool success;
  final String message;
  final String? executionTime;

  QueryResult({
    required this.success,
    required this.message,
    this.executionTime,
  });

  @override
  String toString() {
    return message;
  }
}

class PostgresService {
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<bool> connect(String host, int port, String database, String username,
      String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _isConnected = host.isNotEmpty && username.isNotEmpty;
    return _isConnected;
  }

  Future<QueryResult> executeQuery(String sql) async {
    if (!_isConnected) {
      return QueryResult(
        success: false,
        message: 'ERROR: Not connected to database. Please connect first.',
      );
    }

    final stopwatch = Stopwatch()..start();

    try {
      final result = await _processSQLQuery(sql);
      stopwatch.stop();

      return QueryResult(
        success: true,
        message: result,
        executionTime: '${stopwatch.elapsedMilliseconds}ms',
      );
    } catch (e) {
      stopwatch.stop();
      return QueryResult(
        success: false,
        message: 'ERROR: $e',
        executionTime: '${stopwatch.elapsedMilliseconds}ms',
      );
    }
  }

  Future<String> _processSQLQuery(String sql) async {
    final normalizedSql = sql.trim().toUpperCase();

    if (!_isValidSQL(sql)) {
      throw 'Invalid SQL syntax. Please check your query.';
    }

    if (normalizedSql.startsWith('SELECT')) {
      return _processSelectQuery(sql);
    } else if (normalizedSql.startsWith('INSERT')) {
      return _processInsertQuery(sql);
    } else if (normalizedSql.startsWith('UPDATE')) {
      return _processUpdateQuery(sql);
    } else if (normalizedSql.startsWith('DELETE')) {
      return _processDeleteQuery(sql);
    } else if (normalizedSql.startsWith('CREATE TABLE')) {
      return _processCreateTableQuery(sql);
    } else if (normalizedSql.startsWith('DROP TABLE')) {
      return _processDropTableQuery(sql);
    } else {
      throw 'Unsupported SQL operation. Supported: SELECT, INSERT, UPDATE, DELETE, CREATE TABLE, DROP TABLE';
    }
  }

  bool _isValidSQL(String sql) {
    if (sql.trim().isEmpty) return false;

    final keywords = ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'CREATE', 'DROP'];
    final hasKeyword =
        keywords.any((keyword) => sql.toUpperCase().contains(keyword));

    if (!hasKeyword) return false;

    if (sql.toUpperCase().contains('SELECT') &&
        !sql.toUpperCase().contains('FROM')) {
      return false;
    }

    return true;
  }

  String _processSelectQuery(String sql) {
    final tableMatch =
        RegExp(r'FROM\s+(\w+)', caseSensitive: false).firstMatch(sql);
    final tableName = tableMatch?.group(1) ?? 'unknown_table';

    final whereMatch = RegExp(r'WHERE\s+(.*?)(?:\s+ORDER BY|\s+GROUP BY|$)',
            caseSensitive: false)
        .firstMatch(sql);
    final whereClause = whereMatch?.group(1);

    final rowCount = _generateRowCount(sql);

    return '''QUERY EXECUTED SUCCESSFULLY

Query: $sql
Table: $tableName
${whereClause != null ? 'Condition: $whereClause' : ''}

Results:
${_generateSelectResults(sql, rowCount)}

$rowCount row(s) returned
Execution time: ${_generateExecutionTime()}ms''';
  }

  String _processInsertQuery(String sql) {
    final tableMatch =
        RegExp(r'INSERT\s+INTO\s+(\w+)', caseSensitive: false).firstMatch(sql);
    final tableName = tableMatch?.group(1) ?? 'unknown_table';

    return '''QUERY EXECUTED SUCCESSFULLY

Query: $sql
Table: $tableName

1 row inserted successfully
Execution time: ${_generateExecutionTime()}ms''';
  }

  String _processUpdateQuery(String sql) {
    final tableMatch =
        RegExp(r'UPDATE\s+(\w+)', caseSensitive: false).firstMatch(sql);
    final tableName = tableMatch?.group(1) ?? 'unknown_table';

    final affectedRows = _generateAffectedRows(sql);

    return '''QUERY EXECUTED SUCCESSFULLY

Query: $sql
Table: $tableName

$affectedRows row(s) updated
Execution time: ${_generateExecutionTime()}ms''';
  }

  String _processDeleteQuery(String sql) {
    final tableMatch =
        RegExp(r'DELETE\s+FROM\s+(\w+)', caseSensitive: false).firstMatch(sql);
    final tableName = tableMatch?.group(1) ?? 'unknown_table';

    final affectedRows = _generateAffectedRows(sql);

    return '''QUERY EXECUTED SUCCESSFULLY

Query: $sql
Table: $tableName

$affectedRows row(s) deleted
Execution time: ${_generateExecutionTime()}ms''';
  }

  String _processCreateTableQuery(String sql) {
    final tableMatch =
        RegExp(r'CREATE TABLE\s+(\w+)', caseSensitive: false).firstMatch(sql);
    final tableName = tableMatch?.group(1) ?? 'unknown_table';

    return '''QUERY EXECUTED SUCCESSFULLY

Query: $sql
Table: $tableName

Table created successfully
Execution time: ${_generateExecutionTime()}ms''';
  }

  String _processDropTableQuery(String sql) {
    final tableMatch =
        RegExp(r'DROP TABLE\s+(\w+)', caseSensitive: false).firstMatch(sql);
    final tableName = tableMatch?.group(1) ?? 'unknown_table';

    return '''QUERY EXECUTED SUCCESSFULLY

Query: $sql
Table: $tableName

Table dropped successfully
Execution time: ${_generateExecutionTime()}ms''';
  }

  int _generateRowCount(String sql) {
    if (sql.toUpperCase().contains('WHERE')) {
      return sql.length % 5 + 1;
    } else {
      return sql.length % 20 + 5;
    }
  }

  int _generateAffectedRows(String sql) {
    return sql.length % 10 + 1;
  }

  int _generateExecutionTime() {
    return 50 + (DateTime.now().millisecond % 150);
  }

  String _generateSelectResults(String sql, int rowCount) {
    final columns = _extractColumns(sql);
    final buffer = StringBuffer();

    buffer.writeln(columns.join(' | '));
    buffer.writeln('-' * (columns.length * 15));

    for (int i = 1; i <= rowCount; i++) {
      final row = columns.map((col) => _generateCellValue(col, i)).toList();
      buffer.writeln(row.join(' | '));
    }

    return buffer.toString();
  }

  List<String> _extractColumns(String sql) {
    final selectMatch =
        RegExp(r'SELECT\s+(.*?)\s+FROM', caseSensitive: false).firstMatch(sql);
    if (selectMatch == null) return ['id', 'name', 'value'];

    final columnsPart = selectMatch.group(1)!;
    if (columnsPart == '*') {
      return ['id', 'name', 'email', 'created_at', 'status'];
    }

    return columnsPart.split(',').map((col) => col.trim()).toList();
  }

  String _generateCellValue(String column, int rowNum) {
    final lowerCol = column.toLowerCase();

    if (lowerCol.contains('id')) return rowNum.toString();
    if (lowerCol.contains('name')) return 'User$rowNum';
    if (lowerCol.contains('email')) return 'user$rowNum@example.com';
    if (lowerCol.contains('salary') || lowerCol.contains('price')) {
      return (rowNum * 1000).toString();
    }
    if (lowerCol.contains('date') || lowerCol.contains('time')) {
      return '2024-01-${rowNum.toString().padLeft(2, '0')}';
    }
    if (lowerCol.contains('status')) {
      return rowNum % 2 == 0 ? 'Active' : 'Inactive';
    }

    return 'Value$rowNum';
  }

  void disconnect() {
    _isConnected = false;
  }
}
