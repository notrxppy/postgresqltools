import 'package:flutter/material.dart';
import '../services/postgres_service.dart';

class CompilerPage extends StatefulWidget {
  const CompilerPage({super.key});

  @override
  State<CompilerPage> createState() => _CompilerPageState();
}

class _CompilerPageState extends State<CompilerPage> {
  final TextEditingController _sqlController = TextEditingController();
  final TextEditingController _resultsController = TextEditingController();
  final PostgresService _postgresService = PostgresService();
  bool _isExecuting = false;
  bool _isConnected = false;

  final TextEditingController _hostController =
      TextEditingController(text: 'localhost');
  final TextEditingController _portController =
      TextEditingController(text: '5432');
  final TextEditingController _dbController =
      TextEditingController(text: 'postgres');
  final TextEditingController _userController =
      TextEditingController(text: 'postgres');
  final TextEditingController _passwordController =
      TextEditingController(text: 'password');

  @override
  void initState() {
    super.initState();
    _sqlController.text = 'SELECT id, name, email FROM users LIMIT 3;';
    _resultsController.text = 'Results will appear here...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PostgreSQL Compiler'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Connection Panel
          _buildConnectionPanel(),
          const Divider(),

          Expanded(
            child: Row(
              children: [
                // SQL Editor
                Expanded(
                  child: _buildEditorPanel(),
                ),

                const VerticalDivider(width: 1),

                // Results
                Expanded(
                  child: _buildResultsPanel(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[100],
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _hostController,
              decoration: const InputDecoration(
                labelText: 'Host',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: TextField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: 'Port',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _dbController,
              decoration: const InputDecoration(
                labelText: 'Database',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _userController,
              decoration: const InputDecoration(
                labelText: 'Username',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _isConnected ? _disconnect : _connect,
            icon: Icon(_isConnected ? Icons.link_off : Icons.link),
            label: Text(_isConnected ? 'Disconnect' : 'Connect'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isConnected ? Colors.green : Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorPanel() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'SQL Editor',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _sqlController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText: 'Write your PostgreSQL query here...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: _isExecuting ? null : _executeQuery,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Execute Query'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _clearEditor,
                icon: const Icon(Icons.clear),
                label: const Text('Clear'),
              ),
              const Spacer(),
              _buildConnectionStatus(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultsPanel() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Results',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Text(_resultsController.text),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: _clearResults,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Results'),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Results copied to clipboard')),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy Results'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionStatus() {
    return Row(
      children: [
        Icon(
          _isConnected ? Icons.check_circle : Icons.error,
          color: _isConnected ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          _isConnected ? 'Connected' : 'Disconnected',
          style: TextStyle(
            color: _isConnected ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _connect() async {
    setState(() {
      _isExecuting = true;
    });

    final success = await _postgresService.connect(
      _hostController.text,
      int.tryParse(_portController.text) ?? 5432,
      _dbController.text,
      _userController.text,
      _passwordController.text,
    );

    setState(() {
      _isConnected = success;
      _isExecuting = false;
      _resultsController.text = success
          ? 'Connected successfully to ${_hostController.text}:${_portController.text}/${_dbController.text}'
          : 'Connection failed. Please check your credentials.';
    });
  }

  void _disconnect() {
    _postgresService.disconnect();
    setState(() {
      _isConnected = false;
      _resultsController.text = 'Disconnected from database';
    });
  }

  void _executeQuery() async {
    if (!_isConnected) {
      setState(() {
        _resultsController.text = 'Please connect to a database first';
      });
      return;
    }

    setState(() {
      _isExecuting = true;
      _resultsController.text = 'Executing query...';
    });

    final result = await _postgresService.executeQuery(_sqlController.text);

    setState(() {
      _isExecuting = false;
      _resultsController.text = result.message;
    });
  }

  void _clearEditor() {
    setState(() {
      _sqlController.clear();
    });
  }

  void _clearResults() {
    setState(() {
      _resultsController.clear();
    });
  }
}
