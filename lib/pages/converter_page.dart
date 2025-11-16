import 'package:flutter/material.dart';
import '../services/converter_service.dart';

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final TextEditingController _plsqlController = TextEditingController();
  final TextEditingController _pgsqlController = TextEditingController();
  final ConverterService _converterService = ConverterService();
  bool _isConverting = false;

  @override
  void initState() {
    super.initState();
    _loadSamplePLSQL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PL/SQL to PostgreSQL Converter'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Convert Oracle PL/SQL to PostgreSQL',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // PL/SQL Input
            const Text(
              'PL/SQL Input (Oracle)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _plsqlController,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    hintText: 'Paste Oracle PL/SQL code here...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Convert Button
            ElevatedButton.icon(
              onPressed: _isConverting ? null : _convertCode,
              icon: _isConverting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.translate),
              label: Text(
                  _isConverting ? 'Converting...' : 'Convert to PostgreSQL'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // PostgreSQL Output
            const Text(
              'PostgreSQL Output',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _pgsqlController.text,
                    style: const TextStyle(fontFamily: 'Monospace'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadSamplePLSQL,
                  icon: const Icon(Icons.library_books),
                  label: const Text('Load Sample'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _clearAll,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear All'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _convertCode() async {
    final plsqlCode = _plsqlController.text;
    if (plsqlCode.trim().isEmpty) {
      _showSnackBar('Please enter some PL/SQL code to convert');
      return;
    }

    setState(() {
      _isConverting = true;
      _pgsqlController.text = 'Converting... Please wait.';
    });

    try {
      final convertedCode =
          await _converterService.convertPLSQLToPostgreSQL(plsqlCode);

      setState(() {
        _pgsqlController.text = convertedCode;
      });

      if (convertedCode.contains('CONVERSION SUCCESSFUL') ||
          !convertedCode.contains('ERROR')) {
        _showSnackBar('Conversion completed successfully!');
      }
    } catch (e) {
      setState(() {
        _pgsqlController.text = 'Conversion failed with error: $e';
      });
      _showSnackBar('Conversion failed!');
    } finally {
      setState(() {
        _isConverting = false;
      });
    }
  }

  void _clearAll() {
    setState(() {
      _plsqlController.clear();
      _pgsqlController.clear();
    });
    _showSnackBar('Cleared all content');
  }

  void _loadSamplePLSQL() {
    setState(() {
      _plsqlController.text = '''
DECLARE
  message VARCHAR2(20) := 'Hello, World!';
  counter NUMBER := 1;
  v_salary NUMBER := 5000;
  v_bonus NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE(message);
  
  IF v_salary > 4000 THEN
    v_bonus := v_salary * 0.1;
    DBMS_OUTPUT.PUT_LINE('Bonus: ' || v_bonus);
  ELSE
    v_bonus := v_salary * 0.05;
    DBMS_OUTPUT.PUT_LINE('Small Bonus: ' || v_bonus);
  END IF;
  
  FOR counter IN 1..3 LOOP
    DBMS_OUTPUT.PUT_LINE('Counter: ' || counter);
  END LOOP;
END;
''';
      _pgsqlController.text = 'Click "Convert" to see PostgreSQL version...';
    });
    _showSnackBar('Sample PL/SQL loaded');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
