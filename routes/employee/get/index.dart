import 'package:dart_frog/dart_frog.dart';
import 'package:dartgre_sql/employee_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  final db = EmployeeHelper();

  if (context.request.method == HttpMethod.get) {
    final userIdParam = context.request.uri.queryParameters['userId'];

    if (userIdParam != null && int.tryParse(userIdParam) == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Invalid userId'},
      );
    }
    final todos = await db.getEmployeeList(); // <-- await here
    return Response.json(
      body: {
        'success': true,
        'count': todos.length,
        'data': todos,
      },
    );
  }

  return Response(statusCode: 405);
}
