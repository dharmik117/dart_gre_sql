import 'package:dart_frog/dart_frog.dart';
import 'package:dartgre_sql/todos_helper.dart';

// Future<Response> onRequest(RequestContext context) async {
//   final db = TodosHelper();
//
//   if (context.request.method == HttpMethod.get) {
//     final todos = await db.getAllTodos();
//     return Response.json(body: todos, statusCode: 200);
//   }
//
//   return Response(statusCode: 405);
// }

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.get) {
    try {
      final db = TodosHelper();

      // Get user_id from query params
      final userIdStr = context.request.uri.queryParameters['user_id'];
      if (userIdStr == null) {
        return Response.json(
          body: {'error': 'Missing user_id parameter'},
          statusCode: 400,
        );
      }

      final userId = int.tryParse(userIdStr);
      if (userId == null) {
        return Response.json(
          body: {'error': 'Invalid user_id parameter'},
          statusCode: 400,
        );
      }

      final todos = await db.getTodoById(userId: userId);
      return Response.json(body: todos, statusCode: 200);
    } catch (e, s) {
      print('❌ Error fetching todos: $e');
      print(s);
      return Response.json(
        body: {'error': 'Internal Server Error', 'details': e.toString()},
        statusCode: 500,
      );
    }
  }

  return Response(statusCode: 405);
}
