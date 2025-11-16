import 'package:flutter/material.dart';

class QueryHistoryPage extends StatefulWidget {
  const QueryHistoryPage({super.key});

  @override
  State<QueryHistoryPage> createState() => _QueryHistoryPageState();
}

class _QueryHistoryPageState extends State<QueryHistoryPage> {
  final List<Map<String, String>> _queryHistory = [
    {
      'query': 'SELECT * FROM users LIMIT 10;',
      'timestamp': '2024-01-15 10:30:25',
      'result': 'Success - 10 rows returned'
    },
    {
      'query': 'INSERT INTO products (name, price) VALUES ("Laptop", 999.99);',
      'timestamp': '2024-01-15 10:25:18',
      'result': 'Success - 1 row inserted'
    },
    {
      'query':
          'UPDATE employees SET salary = salary * 1.1 WHERE department = "Engineering";',
      'timestamp': '2024-01-15 09:45:32',
      'result': 'Success - 5 rows updated'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Query History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearHistory,
            tooltip: 'Clear History',
          ),
        ],
      ),
      body: _queryHistory.isEmpty
          ? const Center(
              child: Text(
                'No query history yet',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _queryHistory.length,
              itemBuilder: (context, index) {
                final query = _queryHistory[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.history, color: Colors.blue),
                    title: Text(
                      query['query']!,
                      style: const TextStyle(
                          fontFamily: 'Monospace', fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          query['timestamp']!,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          query['result']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: query['result']!.contains('Success')
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _showQueryDetails(query),
                  ),
                );
              },
            ),
    );
  }

  void _showQueryDetails(Map<String, String> query) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Query Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Query:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  query['query']!,
                  style: const TextStyle(fontFamily: 'Monospace'),
                ),
              ),
              const SizedBox(height: 16),
              Text('Time: ${query['timestamp']}'),
              const SizedBox(height: 8),
              Text('Result: ${query['result']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content:
            const Text('Are you sure you want to clear all query history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _queryHistory.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Query history cleared!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
