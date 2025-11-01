import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dartgre_sql/todos_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  final db = TodosHelper();
  final body = await context.request.body();
  final data = jsonDecode(body) as Map<String, dynamic>;
  final id = data['id'] as int;
  if (context.request.method == HttpMethod.post) {
    final result = await db.deleteTodo(id: id);

    if (result.isNotEmpty) {
      return Response.json(
          body: {'message': 'todo deleted successfully', 'id': id});
    } else {
      return Response.json(body: {'error': 'Todo not found'});
    }
  }
  return Response(statusCode: 405);
}
