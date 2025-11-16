class QueryResultModel {
  final String query;
  final DateTime timestamp;
  final bool success;
  final String result;
  final String? error;
  final int? executionTime;

  QueryResultModel({
    required this.query,
    required this.timestamp,
    required this.success,
    required this.result,
    this.error,
    this.executionTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'query': query,
      'timestamp': timestamp.toIso8601String(),
      'success': success,
      'result': result,
      'error': error,
      'executionTime': executionTime,
    };
  }

  factory QueryResultModel.fromMap(Map<String, dynamic> map) {
    return QueryResultModel(
      query: map['query'],
      timestamp: DateTime.parse(map['timestamp']),
      success: map['success'],
      result: map['result'],
      error: map['error'],
      executionTime: map['executionTime'],
    );
  }
}
