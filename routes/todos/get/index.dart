import 'package:dart_frog/dart_frog.dart';
import 'package:dartgre_sql/todos_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  final db = TodosHelper();

  if (context.request.method == HttpMethod.get) {
    final todos = await db.getAllTodos();
    return Response.json(body: todos, statusCode: 200);
  }

  return Response(statusCode: 405);
}
