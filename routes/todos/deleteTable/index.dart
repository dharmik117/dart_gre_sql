import 'package:dart_frog/dart_frog.dart';
import 'package:dartgre_sql/todos_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.post) {
    try {
      final db = TodosHelper();

      await db.deleteTable();

      return Response.json(
          body: {'message': 'table deleted '}, statusCode: 200);
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
