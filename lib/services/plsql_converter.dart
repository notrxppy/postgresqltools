class PlSqlConverter {
  static String convertPlSqlToPostgres(String plsqlCode) {
    String converted = plsqlCode;

    // Data type conversions
    converted = converted.replaceAllMapped(
      RegExp(r'varchar2\((\d+)\)', caseSensitive: false),
      (match) => 'varchar(${match.group(1)})',
    );

    converted = converted.replaceAllMapped(
      RegExp(r'number\((\d+),\s*(\d+)\)', caseSensitive: false),
      (match) => 'numeric(${match.group(1)},${match.group(2)})',
    );

    converted = converted.replaceAllMapped(
      RegExp(r'number\((\d+)\)', caseSensitive: false),
      (match) => 'numeric(${match.group(1)})',
    );

    converted = converted.replaceAll('NVL(', 'COALESCE(');
    converted = converted.replaceAll('SYSDATE', 'CURRENT_TIMESTAMP');
    converted = converted.replaceAll('TO_DATE(', 'TO_TIMESTAMP(');
    converted = converted.replaceAll('DBMS_OUTPUT.PUT_LINE', 'RAISE NOTICE');

    // Sequence handling
    converted = converted.replaceAllMapped(
      RegExp(r'(\w+)\.nextval', caseSensitive: false),
      (match) => "nextval('${match.group(1)}')",
    );

    // Function return type
    converted = converted.replaceAllMapped(
      RegExp(r'RETURN VARCHAR2', caseSensitive: false),
      (match) => 'RETURNS TEXT',
    );

    converted = converted.replaceAllMapped(
      RegExp(r'RETURN NUMBER', caseSensitive: false),
      (match) => 'RETURNS NUMERIC',
    );

    // Remove Oracle-specific syntax
    converted = converted.replaceAll('CREATE OR REPLACE ', 'CREATE ');

    return converted;
  }
}
