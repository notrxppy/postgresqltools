// PL/SQL to PostgreSQL Converter Service
class ConverterService {
  Future<String> convertPLSQLToPostgreSQL(String plsqlCode) async {
    if (plsqlCode.trim().isEmpty) {
      return 'ERROR: No PL/SQL code provided.';
    }

    await Future.delayed(const Duration(seconds: 1));

    try {
      final validation = _validatePLSQL(plsqlCode);
      if (!validation.isValid) {
        return 'SYNTAX ERRORS:\n${validation.errors.join('\n')}';
      }

      final convertedCode = _convertPLSQLCode(plsqlCode);
      return _formatConversionResult(plsqlCode, convertedCode);
    } catch (e) {
      return 'CONVERSION ERROR: $e';
    }
  }

  ValidationResult _validatePLSQL(String code) {
    final errors = <String>[];
    final upperCode = code.toUpperCase();

    if (!upperCode.contains('DECLARE') && !upperCode.contains('BEGIN')) {
      errors.add('- Missing DECLARE or BEGIN section');
    }

    if (upperCode.contains('BEGIN') && !upperCode.contains('END')) {
      errors.add('- BEGIN without matching END');
    }

    if (code.contains('DESLARE')) {
      errors.add('- Typo: "DESLARE" should be "DECLARE"');
    }

    if (code.contains('donns_output.put_line') ||
        code.contains('doms_output.put_line')) {
      errors.add('- Typo: Should be "DBMS_OUTPUT.PUT_LINE"');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  String _convertPLSQLCode(String plsqlCode) {
    String converted = plsqlCode;

    converted = converted.replaceAll('DESLARE', 'DECLARE');
    converted =
        converted.replaceAll('donns_output.put_line', 'DBMS_OUTPUT.PUT_LINE');
    converted =
        converted.replaceAll('doms_output.put_line', 'DBMS_OUTPUT.PUT_LINE');

    converted = _convertDataTypes(converted);
    converted = _convertFunctions(converted);
    converted = _convertSyntax(converted);

    if (converted.contains('DECLARE') && converted.contains('BEGIN')) {
      converted = _wrapInPostgreSQLBlock(converted);
    }

    return converted;
  }

  String _convertDataTypes(String code) {
    String converted = code;

    converted = converted.replaceAllMapped(
      RegExp(r'VARCHAR2\s*\(\s*(\d+)\s*\)', caseSensitive: false),
      (match) => 'VARCHAR(${match.group(1)})',
    );

    converted = converted.replaceAllMapped(
      RegExp(r'NUMBER\s*\(\s*(\d+)\s*,\s*(\d+)\s*\)', caseSensitive: false),
      (match) => 'NUMERIC(${match.group(1)},${match.group(2)})',
    );

    converted = converted.replaceAllMapped(
      RegExp(r'NUMBER\s*\(\s*(\d+)\s*\)', caseSensitive: false),
      (match) => 'NUMERIC(${match.group(1)})',
    );

    converted = converted.replaceAll('NUMBER', 'NUMERIC');
    converted = converted.replaceAll('DATE', 'TIMESTAMP');

    return converted;
  }

  String _convertFunctions(String code) {
    String converted = code;

    converted = converted.replaceAllMapped(
      RegExp(r'DBMS_OUTPUT\.PUT_LINE\s*\(\s*(.*?)\s*\)\s*;',
          caseSensitive: false),
      (match) {
        final content = match.group(1)!;
        return "RAISE NOTICE '%', $content;";
      },
    );

    converted = converted.replaceAll('SYSDATE', 'CURRENT_TIMESTAMP');
    converted = converted.replaceAll('NVL', 'COALESCE');

    return converted;
  }

  String _convertSyntax(String code) {
    return code.replaceAllMapped(
      RegExp(r'(\w+)\s*:=\s*(.*?);', caseSensitive: false),
      (match) => '${match.group(1)} := ${match.group(2)};',
    );
  }

  String _wrapInPostgreSQLBlock(String code) {
    final buffer = StringBuffer();
    buffer.writeln(r'DO $$');
    buffer.writeln('DECLARE');

    final lines = code.split('\n');
    var inDeclare = false;
    var inBegin = false;

    for (final line in lines) {
      final trimmedLine = line.trim();
      final upperLine = trimmedLine.toUpperCase();

      if (upperLine == 'DECLARE') {
        inDeclare = true;
        continue;
      } else if (upperLine == 'BEGIN') {
        inDeclare = false;
        inBegin = true;
        buffer.writeln('BEGIN');
        continue;
      } else if (upperLine == 'END;' || upperLine == 'END') {
        inBegin = false;
        buffer.writeln('END;');
        continue;
      }

      if (inDeclare && trimmedLine.isNotEmpty) {
        buffer.writeln(trimmedLine);
      } else if (inBegin && trimmedLine.isNotEmpty) {
        buffer.writeln(trimmedLine);
      }
    }

    buffer.writeln(r'$$ LANGUAGE plpgsql;');
    return buffer.toString();
  }

  String _formatConversionResult(String original, String converted) {
    return '''CONVERSION SUCCESSFUL!

ORIGINAL PL/SQL:
----------------------------------------
$original
----------------------------------------

CONVERTED POSTGRESQL:
----------------------------------------
$converted
----------------------------------------

CONVERSION SUMMARY:
• VARCHAR2 → VARCHAR
• NUMBER → NUMERIC
• DATE → TIMESTAMP
• DBMS_OUTPUT.PUT_LINE → RAISE NOTICE
• SYSDATE → CURRENT_TIMESTAMP
• NVL → COALESCE

NOTE: Review the converted code and test thoroughly.''';
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({
    required this.isValid,
    required this.errors,
  });
}
