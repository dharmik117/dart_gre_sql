import 'package:dart_frog/dart_frog.dart';
import 'package:dartgre_sql/auth_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  final db = AuthHelper();

  if (context.request.method == HttpMethod.get) {
    final users = await db.getAllUsers();
    return Response.json(body: users, statusCode: 200);
  } else {
    return Response(statusCode: 405, body: 'Method not allowed');
  }
}
