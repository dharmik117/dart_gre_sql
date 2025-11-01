import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dartgre_sql/todos_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.post) {
    final db = TodosHelper();
    final body = await context.request.body();
    final data = jsonDecode(body) as Map<String, dynamic>;

    final id = data['id'] as int;
    final isLiked = data['is_liked'] as bool;

    final insert = await db.likeUnlikeTodo(id: id, isLiked: isLiked);
    return Response.json(body: insert);
  }

  return Response(statusCode: 405);
}
