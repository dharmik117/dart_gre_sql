import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dartgre_sql/employee_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  final db = EmployeeHelper();

  if (context.request.method != HttpMethod.delete) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  final body = await context.request.body();
  final data = jsonDecode(body) as Map<String, dynamic>;
  final id = int.tryParse(data['employee_id'].toString());

  if (id == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid or missing employee id'},
    );
  }

  final result = await db.deleteEmployeeById(id);
  return Response.json(body: result);
}
