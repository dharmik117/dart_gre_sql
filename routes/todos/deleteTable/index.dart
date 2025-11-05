import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dartgre_sql/todos_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.post) {
    try {
      final db = TodosHelper();

      // Read JSON body
      final body = await context.request.body();
      final data = jsonDecode(body) as Map<String, dynamic>;

      // Get table name from the request
      final tableName = data['table_name'] as String?;

      if (tableName == null || tableName.isEmpty) {
        return Response.json(
          body: {'error': 'table_name is required'},
          statusCode: 400,
        );
      }

      // Call deleteTable method
      await db.deleteTable(tableName: tableName);

      return Response.json(
        body: {'message': 'Table "$tableName" deleted successfully'},
        statusCode: 200,
      );
    } catch (e, s) {
      print('❌ Error deleting table: $e');
      print(s);
      return Response.json(
        body: {'error': 'Internal Server Error', 'details': e.toString()},
        statusCode: 500,
      );
    }
  }

  return Response(statusCode: 405);
}
